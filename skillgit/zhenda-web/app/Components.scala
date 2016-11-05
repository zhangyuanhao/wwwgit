/*
 * Copyright (c) Factchina Inc, 2015-2016
 *
 * This unpublished material is proprietary to Factchina Inc.
 * All rights reserved. The methods and techniques described herein
 * are considered trade secrets and/or confidential.
 * Reproduction or distribution, in whole or in part,
 * is forbidden except by express written permission of Factchina Inc.
 */
import batches.ReIndexInternalGroups
import com.websudos.phantom.connectors.ContactPoint.DefaultPorts
import com.websudos.phantom.connectors._
import elasticsearch._
import filters._
import helpers._
import messages._
import models._
import models.business.customers._
import models.business.individuals._
import models.business.infogathering._
import models.business.providers._
import models.business.reports._
import models.cfs._
import models.fact._
import models.sys.SysConfigs
import play.api.ApplicationLoader.Context
import play.api.LoggerConfigurator
import play.api.i18n._
import play.api.libs.ws.ahc.AhcWSComponents
import play.api.mvc._
import play.filters.gzip.GzipFilterConfig
import router.Routes
import services._
import services.actors._
import services.web.com.cloopen.v20131226.CCPRestSMS
import services.web.gpsso.com.GPSSOIDService
import services.web.ip_api.IPService

import scala.concurrent._
import scala.util.Success

/**
 * @author zepeng.li@factchina.com
 */
class Components(context: Context)
  extends play.api.BuiltInComponentsFromContext(context)
    with I18nComponents
    with AhcWSComponents
    with AppDomainComponents
    with DefaultPlayExecutor
    with Logging {

  LoggerConfigurator(environment.classLoader).foreach {
    _.configure(environment)
  }

  // Prevent thread leaks in dev mode
  applicationLifecycle.addStopHook(() => LeakedThreadsKiller.killPlayInternalExecutionContext())
  applicationLifecycle.addStopHook(() => LeakedThreadsKiller.killTimerInConcurrent())

  // Cassandra Connector
  val contactPoint: KeySpaceBuilder =
    new KeySpaceBuilder(
      _.addContactPoints(
        configuration
          .getStringSeq("cassandra.contact_points")
          .getOrElse(Seq("localhost")): _*
      ).withPort(DefaultPorts.live)
    )

  implicit val keySpaceDef: KeySpaceDef = contactPoint.keySpace(domain.replace(".", "_"))

  applicationLifecycle.addStopHook(
    () => Future.successful {
      // com.websudos.phantom.Manager.shutdown()
      keySpaceDef.session.getCluster.close()
      keySpaceDef.session.close()
      Logger.info("Shutdown Phantom Cassandra Driver")
    }
  )

  // Basic Play Api
  implicit val basicPlayApi = BasicPlayApi(
    langs, messagesApi, environment, configuration, applicationLifecycle, actorSystem, materializer
  )

  // Services
  implicit val bandwidth   = new BandwidthService(basicPlayApi)
  implicit val mailService = new MailService(basicPlayApi)
  implicit val es          = new ElasticSearch(basicPlayApi)
  implicit val ipService   = new IPService(basicPlayApi, wsClient)
  implicit val idService   = new GPSSOIDService(basicPlayApi, wsClient)
  implicit val smsService  = new CCPRestSMS(basicPlayApi, wsClient)
  implicit val fopService  = new FOPService(basicPlayApi)

  // Register permission checkable controllers
  implicit val secured = new controllers.RegisteredSecured(
    controllers.AccessControlsCtrl,
    controllers.api_internal.AccessControlsCtrl,
    controllers.UsersCtrl,
    controllers.api_internal.UsersCtrl,
    controllers.GroupsCtrl,
    controllers.api_internal.GroupsCtrl,
    controllers.FileSystemCtrl,
    controllers.api_internal.FileSystemCtrl,
    controllers.EmailTemplatesCtrl,
    controllers.api_internal.SearchCtrl,
    controllers.api_internal.MessagesCtrl,
    controllers.api_internal.ServicesDefinitionsCtrl,
    controllers.CustomerUserOrdersCtrl,
    controllers.api_internal.CustomerUserOrdersCtrl,
    controllers.BusinessEntitiesCtrl,
    controllers.api_internal.BusinessEntitiesCtrl,
    controllers.CustomersCtrl,
    controllers.api_internal.CustomersCtrl,
    controllers.InstitutionsCtrl,
    controllers.api_internal.InstitutionsCtrl,
    controllers.IndividualsCtrl,
    controllers.api_internal.IndividualsCtrl,
    controllers.EmployeesCtrl,
    controllers.api_internal.EmployeesCtrl,
    controllers.api_internal.EmployeeOrdersCtrl,
    controllers.api_internal.EmployeeCustomersCtrl,
    controllers.TasksCtrl,
    controllers.api_internal.TasksCtrl,
    controllers.BackgroundReportsCtrl,
    controllers.InfoGatheringCtrl,
    controllers.api_internal.InfoGatheringCtrl,
    controllers.api_internal.ResidentIdRecordsCtrl,
    controllers.EmployeeOrdersCtrl,
    controllers.api_internal.EmployeeOrdersCtrl
  )

  // Models
  implicit val _sysConfig      = new SysConfigs
  implicit val _accessControls = new AccessControls
  implicit val _internalGroups = new InternalGroups(
    ig => Future.successful(Unit),
    implicit ig => Future.sequence(
      Seq(
        ReIndexInternalGroups(ig).start(),
        controllers.AccessControlsCtrl.initIfFirstRun,
        controllers.Layouts.initIfFirstRun
      )
    ).andThen { case Success(_) =>
      play.api.Logger.info("InternalGroups/AccessControls have been initialized with default data.")
    }
  )

  implicit val _ipRateLimits            = new IPRateLimits
  implicit val _userLoginIPs            = new UserLoginIPs
  implicit val _users                   = new Users
  implicit val _sessionData             = new SessionData
  implicit val _expirableLinks          = new ExpirableLinks
  implicit val _rateLimits              = new RateLimits
  implicit val _cfs                     = new CassandraFileSystem
  implicit val _groups                  = new Groups
  implicit val _persons                 = new Persons
  implicit val _emailTemplates          = new EmailTemplates
  implicit val _emailTemplateHistories  = new EmailTemplateHistories
  implicit val _chatHistories           = new ChatHistories
  implicit val _mailInbox               = new MailInbox
  implicit val _mailSent                = new MailSent
  implicit val _orders                  = new Orders
  implicit val _employees               = new Employees
  implicit val _individuals             = new Individuals
  implicit val _idRecords               = new ResidentIDRecords
  implicit val _tasks                   = new Tasks
  implicit val _reports                 = new BackgroundReports
  implicit val _institutions            = new Institutions
  implicit val _candidateForms          = new CandidateForms
  implicit val _businessEntities        = new BusinessEntities
  implicit val _customers               = new Customers
  implicit val _providers               = new Providers
  implicit val _mediators               = new Mediators
  implicit val _contracts               = new Contracts
  implicit val _holidays                = new PublicHolidays
  implicit val _periodicallyCleaned     = new PeriodicallyCleaned
  implicit val _ourCompany              = new OurCompany
  implicit val _administrativeDivisions = new AdministrativeDivisions

  play.api.Logger.info("Models have been created.")

  // Actors
  startActors()

  // Error Handler
  override lazy val httpErrorHandler = new ErrorHandler(environment, configuration, sourceMapper, Some(router))

  // Internal Api Permission Checking
  implicit val apiInternalPermCheckRequired =
    controllers.api_internal.UserActionRequired(_users, _accessControls, _rateLimits)

  // Internal Api Controllers
  val apiInternalSearchCtrl                      = new controllers.api_internal.SearchCtrl
  val apiInternalIPCtrl                          = new controllers.api_internal.IPCtrl
  val apiInternalMessagesCtrl                    = new controllers.api_internal.MessagesCtrl
  val apiInternalServicesDefinitionsCtrl         = new controllers.api_internal.ServicesDefinitionsCtrl
  val apiInternalGroupsCtrl                      = new controllers.api_internal.GroupsCtrl
  val apiInternalUsersCtrl                       = new controllers.api_internal.UsersCtrl
  val apiInternalAccessControlsCtrl              = new controllers.api_internal.AccessControlsCtrl
  val apiInternalFileSystemCtrl                  = new controllers.api_internal.FileSystemCtrl
  val apiInternalOrdersCtrl                      = new controllers.api_internal.CustomerUserOrdersCtrl
  val apiInternalEmployeeOrdersCtrl              = new controllers.api_internal.EmployeeOrdersCtrl
  val apiInternalEmployeeCustomerOrdersCtrl      = new controllers.api_internal.EmployeeCustomersCtrl
  val apiInternalEmployeesCtrl                   = new controllers.api_internal.EmployeesCtrl
  val apiInternalIndividualsCtrl                 = new controllers.api_internal.IndividualsCtrl
  val apiInternalIndividualResidentIdRecordsCtrl = new controllers.api_internal.IndividualResidentIdRecordsCtrl
  val apiInternalResidentIdRecordsCtrl           = new controllers.api_internal.ResidentIdRecordsCtrl
  val apiInternalBusinessEntitiesCtrl            = new controllers.api_internal.BusinessEntitiesCtrl
  val apiInternalCustomersCtrl                   = new controllers.api_internal.CustomersCtrl
  val apiInternalInstitutionsCtrl                = new controllers.api_internal.InstitutionsCtrl
  val apiInternalTasksCtrl                       = new controllers.api_internal.TasksCtrl
  val apiInternalInfoGatheringCtrl               = new controllers.api_internal.InfoGatheringCtrl

  play.api.Logger.info("Internal Controllers have been created.")

  // Internal Api Router
  val apiInternalRouter = new api_internal.Routes(
    httpErrorHandler,
    apiInternalSearchCtrl,
    apiInternalIPCtrl,
    apiInternalMessagesCtrl,
    apiInternalServicesDefinitionsCtrl,
    apiInternalGroupsCtrl,
    apiInternalUsersCtrl,
    apiInternalAccessControlsCtrl,
    apiInternalFileSystemCtrl,
    apiInternalOrdersCtrl,
    apiInternalEmployeeOrdersCtrl,
    apiInternalEmployeeCustomerOrdersCtrl,
    apiInternalEmployeesCtrl,
    apiInternalIndividualsCtrl,
    apiInternalIndividualResidentIdRecordsCtrl,
    apiInternalResidentIdRecordsCtrl,
    apiInternalBusinessEntitiesCtrl,
    apiInternalCustomersCtrl,
    apiInternalInstitutionsCtrl,
    apiInternalTasksCtrl,
    apiInternalInfoGatheringCtrl
  )

  // Sockets Controllers
  val userWebSocketCtrl = new controllers.sockets.UserWebSocketCtrl

  // Sockets Router
  val socketsRouter = new sockets.Routes(
    httpErrorHandler,
    userWebSocketCtrl
  )

  // Private Api Controllers
  val apiPrivatePingCtrl = new controllers.api_private.PingCtrl

  // Private Api Router
  val apiPrivateRouter = new api_private.Routes(
    httpErrorHandler,
    apiPrivatePingCtrl
  )

  // Permission Checking
  implicit val permCheckRequired =
    controllers.UserActionRequired(_groups, _accessControls)

  // Root Controllers
  val applicationCtrl       = new controllers.Application
  val experimentalCtrl      = new controllers.ExperimentalCtrl
  val fileSystemCtrl        = new controllers.FileSystemCtrl
  val sessionsCtrl          = new controllers.SessionsCtrl(httpConfiguration, cookieSigner)
  val usersCtrl             = new controllers.UsersCtrl(httpConfiguration, cookieSigner)
  val myCtrl                = new controllers.MyCtrl(httpConfiguration, cookieSigner)
  val groupsCtrl            = new controllers.GroupsCtrl
  val passwordResetCtrl     = new controllers.PasswordResetCtrl
  val emailTemplatesCtrl    = new controllers.EmailTemplatesCtrl
  val accessControlsCtrl    = new controllers.AccessControlsCtrl
  val ordersCtrl            = new controllers.CustomerUserOrdersCtrl
  val employeesCtrl         = new controllers.EmployeesCtrl
  val individualsCtrl       = new controllers.IndividualsCtrl
  val businessEntitiesCtrl  = new controllers.BusinessEntitiesCtrl
  val customersCtrl         = new controllers.CustomersCtrl
  val InstitutionsCtrl      = new controllers.InstitutionsCtrl
  val tasksCtrl             = new controllers.TasksCtrl
  val BackgroundReportsCtrl = new controllers.BackgroundReportsCtrl
  val infoGatheringCtrlCtrl = new controllers.InfoGatheringCtrl
  val employeeOrdersCtrl    = new controllers.EmployeeOrdersCtrl

  play.api.Logger.info("Root Controllers have been created.")

  // Root Router
  lazy val router: Routes = new Routes(
    httpErrorHandler,
    apiInternalRouter,
    socketsRouter,
    apiPrivateRouter,
    applicationCtrl,
    experimentalCtrl,
    new controllers.Assets(httpErrorHandler),
    fileSystemCtrl,
    sessionsCtrl,
    usersCtrl,
    myCtrl,
    groupsCtrl,
    passwordResetCtrl,
    emailTemplatesCtrl,
    accessControlsCtrl,
    ordersCtrl,
    employeesCtrl,
    individualsCtrl,
    businessEntitiesCtrl,
    customersCtrl,
    InstitutionsCtrl,
    tasksCtrl,
    BackgroundReportsCtrl,
    infoGatheringCtrlCtrl,
    employeeOrdersCtrl
  )

  // Http Filters
  override lazy val httpFilters: Seq[EssentialFilter] =
    configuration.getStringSeq("app.http.filters").getOrElse(Nil).collect {
      case "LoopbackIPFilter"          => new LoopbackIPFilter()
      case "InvalidIPFilter"           => new InvalidIPFilter()
      case "RateLimitExceededIPFilter" => new RateLimitExceededIPFilter()
      case "Compressor"                => new Compressor(GzipFilterConfig.fromConfiguration(configuration))
      case "HtmlCompressor"            => new HtmlCompressor(configuration, environment)
      case "RequestLogger"             => new RequestLogger()
      case "RequestTimeLogger"         => new RequestTimeLogger()
    }

  def startActors(): Unit = {
    actorSystem.actorOf(ResourcesManager.props, ResourcesManager.basicName)

    //Start Actor ShardRegion
    MailActor.startRegion(configuration, actorSystem)
    ChatActor.startRegion(configuration, actorSystem)
    NotificationActor.startRegion(configuration, actorSystem)
    IndividualActor.startRegion(configuration, actorSystem)
    CustomerActor.startRegion(configuration, actorSystem)
    CustomerUserActor.startRegion(configuration, actorSystem)
    ProviderActor.startRegion(configuration, actorSystem)
    EmployeeActor.startRegion(configuration, actorSystem)
    MediatorActor.startRegion(configuration, actorSystem)
    CandidateActor.startRegion(configuration, actorSystem)
    OrderProcessor.startRegion(configuration, actorSystem)
    TaskProcessor.startRegion(configuration, actorSystem)
    BackgroundReportProcessor.startRegion(configuration, actorSystem)

    play.api.Logger.info("Actor ShardRegions have been started.")
  }

  play.api.Logger.info("System has been started.")
}