#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

this.views ?= {}
this.views.customers ?= {}

views.customers.customer_svc = angular.module 'customers.customer_svc', []

.factory 'CustomerSvc', [
  ->
    service                 = {}
    service.business_entity = ''
    service.customer_id     = ''
    service.customer        = {}

    service
]

angular.module('app').requires.push 'customers.customer_svc'