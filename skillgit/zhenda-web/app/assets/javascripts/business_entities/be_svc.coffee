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
this.views.business_entities ?= {}

views.business_entities.be_svc = angular.module 'businessEntities.be_svc', []

.factory 'BESvc', [
  ->
    service            = {}
    service.dictionary = {}
    service.id         = ''
    service.value      = {}

    service
]

angular.module('app').requires.push 'businessEntities.be_svc'