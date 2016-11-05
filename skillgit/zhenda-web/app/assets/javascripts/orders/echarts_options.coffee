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
this.views.orders ?= {}

views.orders.echarts_options = angular.module 'orders.echarts_options', []

.constant 'echartsOptions', {

  # 年度委托数据
  monthly_orders_counts_option:
    baseOption:
      tooltip:
          trigger: 'axis'
      legend:
          data:[]
      grid:
          left: '3%'
          right: '4%'
          bottom: '10%'
          containLabel: true
      xAxis:
          type: 'category'
          boundaryGap: false
      yAxis:
          type: 'value'
    media: [
            {
              option:
                legend:
                  right: 'center'
                  bottom: 0
                  orient: 'horizontal'
            }
          ]

  # 报告提交情况
  yearly_on_time_ratio_option:
    tooltip:
      trigger: 'item'
      formatter: "{a} <br/>{b}: {c} ({d}%)"
    legend:
      orient: 'horizontal'
      y: 'bottom'
      data:[]
    grid:
      left: '3%'
      right: '4%'
      bottom: '20%'
    series: [
              {
                name:''
                type:'pie'
                selectedMode: 'single'
                radius: [0, '30%']
                center: ['50%', '40%'],
                label:
                  normal:
                    position: 'inner'
                labelLine:
                  normal:
                    show: false
                data:[]
              },
              {
                name:''
                type:'pie'
                radius: ['40%', '55%']
                center: ['50%', '40%'],
                data:[]
              }
            ]

  # 问题报告占比
  risk_reports_ratio_option:
    baseOption:
      tooltip:
        trigger: 'axis'
        formatter: "{b} <br/>{a}: {c}%"
      legend:
        data:[]
      grid:
          left: '3%'
          right: '4%'
          bottom: '8%'
          containLabel: true
      xAxis:
        type: 'category'
        boundaryGap: true
        data: []
      yAxis:
        type: 'value'
        scale: true
        max: 100,
        min: 0,
        axisLabel:
          formatter : '{value} %'
      series: [
                {
                  name:''
                  type:'bar'
                  barMaxWidth: 100
                  data:[]
                }
              ]
    media: [
            {
              option:
                legend:
                  right: 'center'
                  bottom: 0
                  orient: 'horizontal'
            }
          ]

  # 各类警示灯占比
  lights_ratio_option:
    title :
      text: ''
      x:'center'
    tooltip :
      trigger: 'item'
      formatter: "{a} <br/>{b} : {c} ({d}%)"
    legend:
      orient: 'horizontal'
      y: 'bottom'
      data: []
    grid:
      left: '3%'
      right: '4%'
      bottom: '20%'
    series : [
        {
            name: ''
            type: 'pie'
            radius : '55%'
            center: ['50%', '45%']
            data:[]
            itemStyle:
              emphasis:
                shadowBlur: 10
                shadowOffsetX: 0
                shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
    ]

}