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
# Model User
# -------------------------------------------------------- #
angular.module 'api_internal.user', [ 'ngResource' ]

.factory 'User', [
  '$resource'
  ($resource) ->
    resource = $resource '/api_internal/users/:id/:relations', {
      id        : '@id'
      relations : ''
    }, {

      groups :
        method  : 'GET'
        params  :
          relations : 'groups'
        isArray : true

      externalGroups :
        method  : 'GET'
        params  :
          relations : 'groups'
          options   : 'external'
        isArray : true
    }

    resource.toMap = (usrs) ->
      _.chain usrs
        .map (usr) -> [ usr.id, usr ]
        .object()
        .value()

    return resource
]