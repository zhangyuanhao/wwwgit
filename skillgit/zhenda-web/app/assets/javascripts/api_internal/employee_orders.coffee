#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

# -------------------------------------------------------- #
# Model Employee Orders
# -------------------------------------------------------- #
angular.module 'api_internal.employee_orders', [ 'ngResource' ]

  .factory 'EmployeeOrder', [ '$resource','$http', ($resource, $http) ->
    url = '/api_internal/employee_orders'

    resource = $resource "#{url}/:id/:actions", {
      id      : '@id'
      actions : ''
    }, {
      counts :
        method : 'GET'
        params :
          actions   : 'counts'

      tracks :
        method : 'GET'
        params :
          actions   : 'tracks'
        isArray : true

      listHistoryTasks :
        method : 'GET'
        params :
          actions   : 'list_history_tasks'
        isArray : true

      take :
        method : 'POST'
        params :
          actions   : 'take'
          task_type : '@task_type'

      abandon :
        method : 'POST'
        params :
          actions   : 'abandon'
          task_type : '@task_type'

      withdraw :
        method : 'POST'
        params :
          actions   : 'withdraw'
          task_type : '@task_type'

      publish :
        method : 'POST'
        params :
          actions   : 'publish'

      recontact :
        method : 'POST'
        params :
          actions : 'recontact'

      customerComplained :
        method : 'POST'
        params :
          actions : 'customer_complained'

      expedite :
        method : 'POST'
        params :
          actions : 'expedite'

      infogathering :
        method : 'GET'
        params :
          actions : 'infogathering'

      remove :
        method  : 'POST'
        params  :
          actions : 'remove'
          from  : '@from'
    }

    return resource
  ]