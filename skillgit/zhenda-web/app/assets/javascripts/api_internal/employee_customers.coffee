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
# Model Employee Customers
# -------------------------------------------------------- #
angular.module 'api_internal.employee_customers', [ 'ngResource' ]

  .factory 'EmployeeCustomer', [ '$resource', ($resource) ->
    url = '/api_internal/employee_customers/:cid/:actions'

    resource = $resource "#{url}", {
      cid    : '@cid'
    }, {
      orders :
        method : 'GET'
        params :
          actions : 'orders'
        isArray : true
      follow :
        method : 'POST'
        params :
          actions : ''
      unfollow :
        method : 'DELETE'
        params :
          actions : ''
    }

    return resource
  ]