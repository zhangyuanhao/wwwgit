#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

#
# Helpers.
#
angular.module 'api.helper', []

#
# Helper to display json error message.
#
.factory 'ClientError', ->
  service = {}
  service.unknown = "Unknown Error Occurred."

  service.firstMsg = (resp) ->
    switch resp.status
      when 422 then resp.data.errors?[0].errors?[0].message || @unknown
      else
			 console.log resp #log response for debugging!
			 resp.data?.message || @unknown

  service.messages = (resp, max = 5) ->
    switch resp.status
      when 422
        if resp.data.errors
          msgs = _.chain(resp.data.errors)
            .map((data) -> (_.map data.errors, (error) -> error.message))
            .flatten()
            .value()
          msgs[..max - 1]
        else
          [resp.data.message]
      else [resp.data?.message || @unknown]

  return service

#
# Helper to parse pagination link header, see RFC5988.
#
.factory 'LinkHeader', ->
  service = {}
  service.links = {}

  ###
  Decide whether to use the link on UI based on headers returned from api_internal.

  @param next [String] the next page link on UI
  @param prev [String] the prev page link on UI
  @param headers the headers return from api_internal
  ###
  service.updateLinks = (next, prev, headers) ->
    apiLinks = service.parse headers
    @links.next = if apiLinks.next? then next else undefined
    @links.prev = if apiLinks.prev? then prev else undefined

  ###
  Parse web link header using regex.

  @param headers the headers return from api_internal
  @return [Object] parsed object with 'next' and 'prev' link in it
  ###
  service.parse = (headers) ->
    header   = headers 'Link'
    next     = /<([^<>]+)>; rel="(next)"/g.exec header
    prev     = /<([^<>]+)>; rel="(prev)"/g.exec header
    apiLinks = {}

    apiLinks[next[2]] = next[1] if next?
    apiLinks[prev[2]] = prev[1] if prev?
    apiLinks

  return service