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
# Model AccessControl
# -------------------------------------------------------- #
angular.module 'api_internal.access_control', [ 'ngResource' ]

.factory 'AccessControl', [
  '$resource'
  ($resource) ->
    resource = $resource '/api_internal/access_controls/:principal_id/:resource', {
      principal_id : '@principal_id'
      resource     : '@resource'
    }, {

      create :
        method  : 'POST'
        params  :
          principal_id : ''
          resource     : ''
    }

    resource.gids = (aces) ->
      _.chain aces
        .filter (ace) -> ace.is_group
        .map    (ace) -> ace.principal_id
        .uniq()
        .value()

    resource.uids = (aces) ->
      _.chain aces
        .filter (ace) -> !ace.is_group
        .map    (ace) -> ace.principal_id
        .uniq()
        .value()

    return resource
]