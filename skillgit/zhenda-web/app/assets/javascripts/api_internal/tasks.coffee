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
# Model Task
# -------------------------------------------------------- #
angular.module 'api_internal.task', [ 'ngResource' ]

  .factory 'Task', [ '$resource', '$http', ($resource, $http) ->
    resource = $resource '/api_internal/tasks/:id/:action', {
      id     : '@id'
      action : ''
    }, {
      reviewRequest :
        method  : 'POST'
        params  :
          action : 'review_request'

      finallyPass :
        method  : 'POST'
        params  :
          action : 'review_finally_pass'

      basicallyPass :
        method  : 'POST'
        params  :
          action : 'review_basically_pass'

      partiallyPass :
        method  : 'POST'
        params  :
          action : 'review_partially_pass'

      reject :
        method  : 'POST'
        params  :
          action : 'review_reject'

      complained :
        method  : 'POST'
        params  :
          action : 'review_complained'
    }

    resource.lastEvent = (id) ->
      $http.get "/api_internal/tasks/#{id}/events/last"

    resource.events = (id) ->
      $http.get "/api_internal/tasks/#{id}/events"

    return resource
  ]