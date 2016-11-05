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
# Model Group
# -------------------------------------------------------- #
angular.module 'api_internal.group', [ 'ngResource' ]

.factory 'Group', [
  '$resource'
  '$http'
  ($resource, $http) ->
    resource = $resource '/api_internal/groups/:id/:relations/:uid', {
      id        : '@id'
      relations : ''
      uid       : ''
    }, {

      users :
        method  : 'GET'
        params  :
          relations : 'users'
        isArray : true

      addUser :
        method  : 'POST'
        params  :
          relations : 'users'
          uid       : '@uid'

      delUser :
        method  : 'DELETE'
        params  :
          relations : 'users'
          uid       : '@uid'
    }

    resource.layouts = (ids) ->
      $http.get "/api_internal/layouts", params : ids : ids.join(',')

    resource.setLayout = (gid, layout) ->
      $http.post "/api_internal/layouts/#{gid}", layout : layout

    resource.delLayout = (gid) ->
      $http.delete "/api_internal/layouts/#{gid}"

    resource.toMap = (grps) ->
      _.chain grps
        .map (grp) -> [ grp.id, grp ]
        .object()
        .value()

    return resource
]