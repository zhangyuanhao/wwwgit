organization := "com.factchina"
version      := "1.0.0-SNAPSHOT"
name         := "zhenda-web"

scalaVersion  := "2.11.8"
scalacOptions += "-feature"

LessKeys.compress in Assets := true

includeFilter in (Assets, LessKeys.less) := "*.less"

excludeFilter in (Assets, LessKeys.less) := "_*.less"

pipelineStages := Seq(uglify, gzip)

lazy val web = (project in file(".")).enablePlugins(PlayScala)

routesGenerator := InjectedRoutesGenerator

libraryDependencies ++= Seq(
  "com.factchina"     %% "zhenda-api-internal"        % "1.0.0-SNAPSHOT",
  "com.factchina"     %% "zhenda-api-private"         % "1.0.0-SNAPSHOT",
  "com.factchina"     %% "zhenda-sockets"             % "1.0.0-SNAPSHOT",
  "org.webjars.bower" %  "bootstrap"                  % "3.3.6",
  "org.webjars.bower" %  "font-awesome"               % "4.4.0",
  "org.webjars.bower" %  "holderjs"                   % "2.6.0",
  "org.webjars.bower" %  "angular-xeditable"          % "0.1.9",
  "org.webjars.bower" %  "angular-bootstrap"          % "1.3.3",
  "org.webjars.bower" %  "angular-resource"           % "1.4.4",
  "org.webjars.bower" %  "angular-animate"            % "1.4.4",
  "org.webjars.bower" %  "angular-sanitize"           % "1.4.4",
  "org.webjars.bower" %  "angular-i18n"               % "1.4.4",
  "org.webjars.bower" %  "angular-cookies"            % "1.4.4",
  "org.webjars.bower" %  "underscore"                 % "1.8.3",
  "org.webjars.bower" %  "animate.css"                % "3.5.1",
  "org.webjars.bower" %  "ng-flow"                    % "2.6.1",
  "org.webjars.bower" %  "metisMenu"                  % "2.5.0",
  "org.webjars.bower" %  "pace"                       % "1.0.2",
  "org.webjars.bower" %  "awesome-bootstrap-checkbox" % "0.3.7",
  "org.webjars.bower" %  "echarts"                    % "3.1.5",
  "org.webjars.npm"   %  "angular-ui-router"          % "1.0.0-alpha.5",
  "org.webjars.bower" %  "sweetalert2"                % "4.0.8",
  "org.webjars.bower" %  "flag-icon-css"              % "2.3.1",
  "org.webjars.bower" %  "signature_pad"              % "1.5.3"
)

dependencyOverrides ++= Set(
 "org.webjars.bower" % "angular" % "1.4.4",
 "org.webjars.bower" % "jquery"  % "2.2.4"
)

libraryDependencies ++= Seq(
  specs2                                        % Test,
  "com.codeborne" % "phantomjsdriver" % "1.2.1" % Test
)

resolvers += "scalaz-bintray" at "https://dl.bintray.com/scalaz/releases"

TwirlKeys.templateImports ++= Seq(
  "elasticsearch.SortField",
  "helpers.ExtDateTimeFormat._",
  "helpers.syntax._",
  "java.util.UUID",
  "models.business.customers._",
  "models.business.providers._",
  "models.business.individuals._",
  "models.cfs._",
  "models.fact._",
  "models.misc._",
  "org.joda.time._",
  "play.api.Environment",
  "play.api.i18n.{Messages => MSG}",
  "scala.util._",
  "security._"
)

TwirlKeys.templateFormats += ("fo" -> "play.twirl.api.XmlFormat")

routesImport ++= Seq(
  "elasticsearch.SortField",
  "helpers.ExtBindable._",
  "java.util.UUID",
  "models.cfs._",
  "models.misc._",
  "org.joda.time.DateTime",
  "play.api.i18n.Lang",
  "scala.language.reflectiveCalls",
  "models.business.providers._"
)