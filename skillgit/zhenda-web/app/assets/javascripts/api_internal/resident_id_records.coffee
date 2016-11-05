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
# Model ResidentIDRecord
# -------------------------------------------------------- #
angular.module 'api_internal.resident_id_record', [ 'ngResource' ]

  .factory 'ResidentIDRecord', [ '$resource', '$http', ($resource, $http) ->
    resource = $resource '/api_internal/resident_id_records/:id',
      id : '@id'

    return resource
  ]