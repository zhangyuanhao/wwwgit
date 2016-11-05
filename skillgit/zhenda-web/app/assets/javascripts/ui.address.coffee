#
# Copyright (c) Factchina Inc, 2015-2016
#
# This unpublished material is proprietary to Factchina Inc.
# All rights reserved. The methods and techniques described herein
# are considered trade secrets and/or confidential.
# Reproduction or distribution, in whole or in part,
# is forbidden except by express written permission of Factchina Inc.
#

angular.module 'ui.address', ['ui.address.html']

.constant 'addressConfig', {
  "countries" :
    "CN" : "中国"

  "address_china" :
    "北京" :
      "朝阳区" : "朝阳区"
      "海淀区" : "海淀区"
      "西城区" : "西城区"
      "东城区" : "东城区"
      "崇文区" : "崇文区"
      "宣武区" : "宣武区"
      "丰台区" : "丰台区"
      "石景山区" : "石景山区"
      "门头沟" : "门头沟"
      "房山区" : "房山区"
      "通州区" : "通州区"
      "大兴区" : "大兴区"
      "顺义区" : "顺义区"
      "怀柔区" : "怀柔区"
      "密云区" : "密云区"
      "昌平区" : "昌平区"
      "平谷区" : "平谷区"
      "延庆县" : "延庆县"
    "上海" :
      "黄浦区" : "黄浦区"
      "徐汇区" : "徐汇区"
      "长宁区" : "长宁区"
      "静安区" : "静安区"
      "闸北区" : "闸北区"
      "虹口区" : "虹口区"
      "杨浦区" : "杨浦区"
      "宝山区" : "宝山区"
      "闵行区" : "闵行区"
      "嘉定区" : "嘉定区"
      "浦东新区" : "浦东新区"
      "青浦区" : "青浦区"
      "松江区" : "松江区"
      "金山区" : "金山区"
      "奉贤区" : "奉贤区"
      "普陀区" : "普陀区"
      "崇明区" : "崇明区"
    "天津" :
      "东丽区" : "东丽区"
      "和平区" : "和平区"
      "河北区" : "河北区"
      "河东区" : "河东区"
      "河西区" : "河西区"
      "红桥区" : "红桥区"
      "蓟县" : "蓟县"
      "静海县" : "静海县"
      "南开区" : "南开区"
      "塘沽区" : "塘沽区"
      "西青区" : "西青区"
      "武清区" : "武清区"
      "津南区" : "津南区"
      "汉沽区" : "汉沽区"
      "大港区" : "大港区"
      "北辰区" : "北辰区"
      "宝坻区" : "宝坻区"
      "宁河县" : "宁河县"
    "重庆" :
      "万州区" : "万州区"
      "涪陵区" : "涪陵区"
      "梁平县" : "梁平县"
      "南川区" : "南川区"
      "潼南县" : "潼南县"
      "大足区" : "大足区"
      "黔江区" : "黔江区"
      "武隆县" : "武隆县"
      "丰都县" : "丰都县"
      "奉节县" : "奉节县"
      "开县" : "开县"
      "云阳县" : "云阳县"
      "忠县" : "忠县"
      "巫溪县" : "巫溪县"
      "巫山县" : "巫山县"
      "石柱县" : "石柱县"
      "彭水县" : "彭水县"
      "垫江县" : "垫江县"
      "酉阳县" : "酉阳县"
      "秀山县" : "秀山县"
      "城口县" : "城口县"
      "璧山县" : "璧山县"
      "荣昌县" : "荣昌县"
      "铜梁县" : "铜梁县"
      "合川区" : "合川区"
      "巴南区" : "巴南区"
      "北碚区" : "北碚区"
      "江津区" : "江津区"
      "渝北区" : "渝北区"
      "长寿区" : "长寿区"
      "永川区" : "永川区"
      "江北区" : "江北区"
      "南岸区" : "南岸区"
      "九龙坡区" : "九龙坡区"
      "沙坪坝区" : "沙坪坝区"
      "大渡口区" : "大渡口区"
      "綦江区" : "綦江区"
      "渝中区" : "渝中区"
      "高新区" : "高新区"
      "北部新区" : "北部新区"
    "河北" :
      "石家庄市" : "石家庄市"
      "邯郸市" : "邯郸市"
      "邢台市" : "邢台市"
      "保定市" : "保定市"
      "张家口市" : "张家口市"
      "承德市" : "承德市"
      "秦皇岛市" : "秦皇岛市"
      "唐山市" : "唐山市"
      "沧州市" : "沧州市"
      "廊坊市" : "廊坊市"
      "衡水市" : "衡水市"
    "山西" :
      "太原市" : "太原市"
      "大同市" : "大同市"
      "阳泉市" : "阳泉市"
      "晋城市" : "晋城市"
      "朔州市" : "朔州市"
      "晋中市" : "晋中市"
      "忻州市" : "忻州市"
      "吕梁市" : "吕梁市"
      "临汾市" : "临汾市"
      "运城市" : "运城市"
      "长治市" : "长治市"
    "河南" :
      "郑州市" : "郑州市"
      "开封市" : "开封市"
      "洛阳市" : "洛阳市"
      "平顶山市" : "平顶山市"
      "焦作市" : "焦作市"
      "鹤壁市" : "鹤壁市"
      "新乡市" : "新乡市"
      "安阳市" : "安阳市"
      "濮阳市" : "濮阳市"
      "许昌市" : "许昌市"
      "漯河市" : "漯河市"
      "三门峡市" : "三门峡市"
      "南阳市" : "南阳市"
      "商丘市" : "商丘市"
      "周口市" : "周口市"
      "驻马店市" : "驻马店市"
      "信阳市" : "信阳市"
      "济源市" : "济源市"
    "辽宁" :
      "沈阳市" : "沈阳市"
      "大连市" : "大连市"
      "鞍山市" : "鞍山市"
      "抚顺市" : "抚顺市"
      "本溪市" : "本溪市"
      "丹东市" : "丹东市"
      "锦州市" : "锦州市"
      "葫芦岛市" : "葫芦岛市"
      "营口市" : "营口市"
      "盘锦市" : "盘锦市"
      "阜新市" : "阜新市"
      "辽阳市" : "辽阳市"
      "朝阳市" : "朝阳市"
      "铁岭市" : "铁岭市"
    "吉林" :
      "长春市" : "长春市"
      "吉林市" : "吉林市"
      "四平市" : "四平市"
      "通化市" : "通化市"
      "白山市" : "白山市"
      "松原市" : "松原市"
      "白城市" : "白城市"
      "延边州" : "延边州"
      "辽源市" : "辽源市"
    "黑龙江" :
      "哈尔滨市" : "哈尔滨市"
      "齐齐哈尔市" : "齐齐哈尔市"
      "鹤岗市" : "鹤岗市"
      "双鸭山市" : "双鸭山市"
      "鸡西市" : "鸡西市"
      "大庆市" : "大庆市"
      "伊春市" : "伊春市"
      "牡丹江市" : "牡丹江市"
      "佳木斯市" : "佳木斯市"
      "七台河市" : "七台河市"
      "黑河市" : "黑河市"
      "绥化市" : "绥化市"
      "大兴安岭地区" : "大兴安岭地区"
    "内蒙古" :
      "呼和浩特市" : "呼和浩特市"
      "包头市" : "包头市"
      "乌海市" : "乌海市"
      "赤峰市" : "赤峰市"
      "乌兰察布市" : "乌兰察布市"
      "锡林郭勒盟" : "锡林郭勒盟"
      "呼伦贝尔市" : "呼伦贝尔市"
      "鄂尔多斯市" : "鄂尔多斯市"
      "巴彦淖尔市" : "巴彦淖尔市"
      "阿拉善盟" : "阿拉善盟"
      "兴安盟" : "兴安盟"
      "通辽市" : "通辽市"
    "江苏" :
      "南京市" : "南京市"
      "徐州市" : "徐州市"
      "连云港市" : "连云港市"
      "淮安市" : "淮安市"
      "宿迁市" : "宿迁市"
      "盐城市" : "盐城市"
      "扬州市" : "扬州市"
      "泰州市" : "泰州市"
      "南通市" : "南通市"
      "镇江市" : "镇江市"
      "常州市" : "常州市"
      "无锡市" : "无锡市"
      "苏州市" : "苏州市"
    "山东" :
      "济南市" : "济南市"
      "青岛市" : "青岛市"
      "淄博市" : "淄博市"
      "枣庄市" : "枣庄市"
      "东营市" : "东营市"
      "潍坊市" : "潍坊市"
      "烟台市" : "烟台市"
      "威海市" : "威海市"
      "莱芜市" : "莱芜市"
      "德州市" : "德州市"
      "临沂市" : "临沂市"
      "聊城市" : "聊城市"
      "滨州市" : "滨州市"
      "菏泽市" : "菏泽市"
      "日照市" : "日照市"
      "泰安市" : "泰安市"
      "济宁市" : "济宁市"
    "安徽" :
      "铜陵市" : "铜陵市"
      "合肥市" : "合肥市"
      "淮南市" : "淮南市"
      "淮北市" : "淮北市"
      "芜湖市" : "芜湖市"
      "蚌埠市" : "蚌埠市"
      "马鞍山市" : "马鞍山市"
      "安庆市" : "安庆市"
      "黄山市" : "黄山市"
      "滁州市" : "滁州市"
      "阜阳市" : "阜阳市"
      "亳州市" : "亳州市"
      "宿州市" : "宿州市"
      "池州市" : "池州市"
      "六安市" : "六安市"
      "宣城市" : "宣城市"
    "浙江" :
      "宁波市" : "宁波市"
      "杭州市" : "杭州市"
      "温州市" : "温州市"
      "嘉兴市" : "嘉兴市"
      "湖州市" : "湖州市"
      "绍兴市" : "绍兴市"
      "金华市" : "金华市"
      "衢州市" : "衢州市"
      "丽水市" : "丽水市"
      "台州市" : "台州市"
      "舟山市" : "舟山市"
    "福建" :
      "福州市" : "福州市"
      "厦门市" : "厦门市"
      "三明市" : "三明市"
      "莆田市" : "莆田市"
      "泉州市" : "泉州市"
      "漳州市" : "漳州市"
      "南平市" : "南平市"
      "龙岩市" : "龙岩市"
      "宁德市" : "宁德市"
    "湖北" :
      "武汉市" : "武汉市"
      "黄石市" : "黄石市"
      "襄阳市" : "襄阳市"
      "十堰市" : "十堰市"
      "荆州市" : "荆州市"
      "宜昌市" : "宜昌市"
      "孝感市" : "孝感市"
      "黄冈市" : "黄冈市"
      "咸宁市" : "咸宁市"
      "恩施州" : "恩施州"
      "鄂州市" : "鄂州市"
      "荆门市" : "荆门市"
      "随州市" : "随州市"
      "潜江市" : "潜江市"
      "天门市" : "天门市"
      "仙桃市" : "仙桃市"
      "神农架林区" : "神农架林区"
    "湖南" :
      "长沙市" : "长沙市"
      "株洲市" : "株洲市"
      "湘潭市" : "湘潭市"
      "韶山市" : "韶山市"
      "衡阳市" : "衡阳市"
      "邵阳市" : "邵阳市"
      "岳阳市" : "岳阳市"
      "常德市" : "常德市"
      "张家界市" : "张家界市"
      "郴州市" : "郴州市"
      "益阳市" : "益阳市"
      "永州市" : "永州市"
      "怀化市" : "怀化市"
      "娄底市" : "娄底市"
      "湘西州" : "湘西州"
    "广东" :
      "广州市" : "广州市"
      "深圳市" : "深圳市"
      "珠海市" : "珠海市"
      "汕头市" : "汕头市"
      "韶关市" : "韶关市"
      "河源市" : "河源市"
      "梅州市" : "梅州市"
      "惠州市" : "惠州市"
      "汕尾市" : "汕尾市"
      "东莞市" : "东莞市"
      "中山市" : "中山市"
      "江门市" : "江门市"
      "佛山市" : "佛山市"
      "阳江市" : "阳江市"
      "湛江市" : "湛江市"
      "茂名市" : "茂名市"
      "肇庆市" : "肇庆市"
      "云浮市" : "云浮市"
      "清远市" : "清远市"
      "潮州市" : "潮州市"
      "揭阳市" : "揭阳市"
    "广西" :
      "南宁市" : "南宁市"
      "柳州市" : "柳州市"
      "桂林市" : "桂林市"
      "梧州市" : "梧州市"
      "北海市" : "北海市"
      "防城港市" : "防城港市"
      "钦州市" : "钦州市"
      "贵港市" : "贵港市"
      "玉林市" : "玉林市"
      "贺州市" : "贺州市"
      "百色市" : "百色市"
      "河池市" : "河池市"
      "来宾市" : "来宾市"
      "崇左市" : "崇左市"
    "江西" :
      "南昌市" : "南昌市"
      "景德镇市" : "景德镇市"
      "萍乡市" : "萍乡市"
      "新余市" : "新余市"
      "九江市" : "九江市"
      "鹰潭市" : "鹰潭市"
      "上饶市" : "上饶市"
      "宜春市" : "宜春市"
      "抚州市" : "抚州市"
      "吉安市" : "吉安市"
      "赣州市" : "赣州市"
    "四川" :
      "成都市" : "成都市"
      "自贡市" : "自贡市"
      "攀枝花市" : "攀枝花市"
      "泸州市" : "泸州市"
      "绵阳市" : "绵阳市"
      "德阳市" : "德阳市"
      "广元市" : "广元市"
      "遂宁市" : "遂宁市"
      "内江市" : "内江市"
      "乐山市" : "乐山市"
      "宜宾市" : "宜宾市"
      "广安市" : "广安市"
      "南充市" : "南充市"
      "达州市" : "达州市"
      "巴中市" : "巴中市"
      "雅安市" : "雅安市"
      "眉山市" : "眉山市"
      "资阳市" : "资阳市"
      "阿坝州" : "阿坝州"
      "甘孜州" : "甘孜州"
      "凉山州" : "凉山州"
    "海南" :
      "海口市" : "海口市"
      "儋州市" : "儋州市"
      "琼海市" : "琼海市"
      "万宁市" : "万宁市"
      "东方市" : "东方市"
      "三亚市" : "三亚市"
      "文昌市" : "文昌市"
      "五指山市" : "五指山市"
      "临高县" : "临高县"
      "澄迈县" : "澄迈县"
      "定安县" : "定安县"
      "屯昌县" : "屯昌县"
      "昌江县" : "昌江县"
      "白沙县" : "白沙县"
      "琼中县" : "琼中县"
      "陵水县" : "陵水县"
      "保亭县" : "保亭县"
      "乐东县" : "乐东县"
      "三沙市" : "三沙市"
    "贵州" :
      "贵阳市" : "贵阳市"
      "六盘水市" : "六盘水市"
      "遵义市" : "遵义市"
      "铜仁市" : "铜仁市"
      "毕节市" : "毕节市"
      "安顺市" : "安顺市"
      "黔西南州" : "黔西南州"
      "黔东南州" : "黔东南州"
      "黔南州" : "黔南州"
    "云南" :
      "昆明市" : "昆明市"
      "曲靖市" : "曲靖市"
      "玉溪市" : "玉溪市"
      "昭通市" : "昭通市"
      "普洱市" : "普洱市"
      "临沧市" : "临沧市"
      "保山市" : "保山市"
      "丽江市" : "丽江市"
      "文山州" : "文山州"
      "红河州" : "红河州"
      "西双版纳州" : "西双版纳州"
      "楚雄州" : "楚雄州"
      "大理州" : "大理州"
      "德宏州" : "德宏州"
      "怒江州" : "怒江州"
      "迪庆州" : "迪庆州"
    "西藏" :
      "拉萨市" : "拉萨市"
      "那曲地区" : "那曲地区"
      "山南地区" : "山南地区"
      "昌都地区" : "昌都地区"
      "日喀则地区" : "日喀则地区"
      "阿里地区" : "阿里地区"
      "林芝地区" : "林芝地区"
    "陕西" :
      "西安市" : "西安市"
      "铜川市" : "铜川市"
      "宝鸡市" : "宝鸡市"
      "咸阳市" : "咸阳市"
      "渭南市" : "渭南市"
      "延安市" : "延安市"
      "汉中市" : "汉中市"
      "榆林市" : "榆林市"
      "商洛市" : "商洛市"
      "安康市" : "安康市"
    "甘肃" :
      "兰州市" : "兰州市"
      "金昌市" : "金昌市"
      "白银市" : "白银市"
      "天水市" : "天水市"
      "嘉峪关市" : "嘉峪关市"
      "平凉市" : "平凉市"
      "庆阳市" : "庆阳市"
      "陇南市" : "陇南市"
      "武威市" : "武威市"
      "张掖市" : "张掖市"
      "酒泉市" : "酒泉市"
      "甘南州" : "甘南州"
      "临夏州" : "临夏州"
      "定西市" : "定西市"
    "青海" :
      "西宁市" : "西宁市"
      "海东地区" : "海东地区"
      "海北州" : "海北州"
      "黄南州" : "黄南州"
      "海南州" : "海南州"
      "果洛州" : "果洛州"
      "玉树州" : "玉树州"
      "海西州" : "海西州"
    "宁夏" :
      "银川市" : "银川市"
      "石嘴山市" : "石嘴山市"
      "吴忠市" : "吴忠市"
      "固原市" : "固原市"
      "中卫市" : "中卫市"
    "新疆" :
      "乌鲁木齐市" : "乌鲁木齐市"
      "克拉玛依市" : "克拉玛依市"
      "石河子市" : "石河子市"
      "吐鲁番地区" : "吐鲁番地区"
      "哈密地区" : "哈密地区"
      "和田地区" : "和田地区"
      "阿克苏地区" : "阿克苏地区"
      "喀什地区" : "喀什地区"
      "克孜勒苏州" : "克孜勒苏州"
      "巴音郭楞州" : "巴音郭楞州"
      "昌吉州" : "昌吉州"
      "博尔塔拉州" : "博尔塔拉州"
      "伊犁州"  : "伊犁州"
      "塔城地区" : "塔城地区"
      "阿勒泰地区" : "阿勒泰地区"
      "五家渠市" : "五家渠市"
      "阿拉尔市" : "阿拉尔市"
      "图木舒克市" : "图木舒克市"
    "台湾" :
      "台湾" : "台湾"
    "香港" :
      "香港特别行政区" : "香港特别行政区"
    "澳门" :
      "澳门市" : "澳门市"
}

.factory 'AddressCheck', ->
  service = {}

  service.isEmpty = (value)->
    !value or value.length is 0

  service.addressValidator = (address, province_check, city_check, street_check)->
    retValue = true
    if address?
      if province_check
        switch address.country
          when 'CN','ZA','KR','CA','IT','UA','RU','ES','BY','TH' then retValue = false if @isEmpty(address.province)
          when 'EG' then retValue = false if @isEmpty(address.governorate)
          when 'AU','MY','US' then retValue = false if @isEmpty(address.state)
          when 'GB','IE','TW' then retValue = false if @isEmpty(address.county)
          when 'JP' then retValue = false if @isEmpty(address.prefecture)
          when 'HK','MO' then retValue = false if @isEmpty(address.region)
          else retValue = false if @isEmpty(address.city)

      if city_check
        switch address.country
          when 'CN','ZA','KR','CA','IT','UA','RU','ES','BY','MY','US','GB','IE','MO' then retValue = false if @isEmpty(address.city)
          when 'TH','PH','EG','HK' then retValue = false if @isEmpty(address.district)
          when 'NZ','AU' then retValue = false if @isEmpty(address.suburb)
          when 'JP' then retValue = false if @isEmpty(address.country_city)
          when 'TW' then retValue = false if @isEmpty(address.township)

      if street_check
        if address.country is "JP"
          retValue = false if @isEmpty(address.further_divisions1)
        else
          retValue = false if @isEmpty(address.street1)

    retValue

  service

.controller 'AddressController', [
  '$scope'
  'addressConfig'
  'AddressCheck'
  ($scope, addressConfig, AddressCheck) ->
    $scope.provinceRequired = 'false'
    $scope.cityRequired     = 'false'
    $scope.streetRequired   = 'false'

    # CN:中国, ZA:南非, KR:韩国, CA:加拿大, IT:意大利, UA:乌克兰, RU:俄罗斯, ES:西班牙, BY:白俄罗斯
    $scope.address001 =
      postal_code : ""
      province    : ""
      city        : ""
      street1     : ""
      street2     : ""

    # TH:泰国
    $scope.address002 =
      postal_code : ""
      province    : ""
      district    : ""
      street1     : ""
      street2     : ""

    # PH:菲律宾
    $scope.address003 =
      post_code : ""
      city      : ""
      district  : ""
      street1   : ""
      street2   : ""

    # EG:埃及
    $scope.address004 =
      governorate : ""
      district    : ""
      street1     : ""
      street2     : ""

    # NZ:新西兰
    $scope.address005 =
      postal_code : ""
      city        : ""
      suburb      : ""
      street1     : ""
      street2     : ""

    # AU:澳大利亚
    $scope.address006 =
      postal_code : ""
      state       : ""
      suburb      : ""
      street1     : ""
      street2     : ""

    # MY:马来西亚
    $scope.address007 =
      postal_code : ""
      state       : ""
      city        : ""
      street1     : ""
      street2     : ""

    # GB:英国, IE:爱尔兰
    $scope.address008 =
      post_code : ""
      county    : ""
      city      : ""
      street1   : ""
      street2   : ""

    # CM:喀麦隆
    $scope.address009 =
      city        : ""
      street1     : ""
      street2     : ""

    # US:美国
    $scope.address010 =
      zip     : ""
      state   : ""
      city    : ""
      street1 : ""
      street2 : ""

    # JP:日本
    $scope.address011 =
      postal_code        : ""
      prefecture         : ""
      country_city       : ""
      further_divisions1 : ""
      further_divisions2 : ""

    # TW:台湾
    $scope.address012 =
      zip      : ""
      county   : ""
      township : ""
      street1  : ""
      street2  : ""

    # HK:香港
    $scope.address013 =
      region   : ""
      district : ""
      street1  : ""
      street2  : ""

    # MO:澳门
    $scope.address014 =
      region  : ""
      city    : ""
      street1 : ""
      street2 : ""

    # 其它
    $scope.address100 =
      postal_code : ""
      city        : ""
      street1     : ""
      street2     : ""

    if !$scope.ngModel
      $scope.ngModel = angular.copy $scope.address001
      $scope.ngModel.country = "CN"

    $scope.inArray = (array, item)->
      _.contains(array, item)

    $scope.addressCheck = ->
      province_check = true if $scope.provinceRequired is 'true'
      city_check     = true if $scope.showCity is 'true' and $scope.cityRequired is 'true'
      street_check   = true if $scope.showStreet is 'true' and $scope.streetRequired is 'true'
      if !AddressCheck.addressValidator($scope.ngModel, province_check, city_check, street_check)
        $scope.requireInvalid = true
      else
        $scope.requireInvalid = false

    $scope.initProvinces = ->
      keys = _.keys addressConfig.address_china
      $scope.provinces = "" : "请选择"
      for key in keys
        $scope.provinces[key] = key

    $scope.initCitys = ->
      $scope.citys = "" : "请选择"
      if $scope.ngModel?
        keys = _.keys addressConfig.address_china[$scope.ngModel.province]
        for key in keys
          $scope.citys[key] = key

    $scope.reloadAddress = (country_code)->
      switch country_code
        when 'CN','ZA','KR','CA','IT','UA','RU','ES','BY' then angular.copy $scope.ngModel = $scope.address001
        when 'TH' then angular.copy $scope.ngModel = $scope.address002
        when 'PH' then angular.copy $scope.ngModel = $scope.address003
        when 'EG' then angular.copy $scope.ngModel = $scope.address004
        when 'NZ' then angular.copy $scope.ngModel = $scope.address005
        when 'AU' then angular.copy $scope.ngModel = $scope.address006
        when 'MY' then angular.copy $scope.ngModel = $scope.address007
        when 'GB','IE' then angular.copy $scope.ngModel = $scope.address008
        when 'CM' then angular.copy $scope.ngModel = $scope.address009
        when 'US' then angular.copy $scope.ngModel = $scope.address010
        when 'JP' then angular.copy $scope.ngModel = $scope.address011
        when 'TW' then angular.copy $scope.ngModel = $scope.address012
        when 'HK' then angular.copy $scope.ngModel = $scope.address013
        when 'MO' then angular.copy $scope.ngModel = $scope.address014
        else angular.copy $scope.ngModel = $scope.address100
      $scope.ngModel.country = country_code
      $scope.addressCheck()

    $scope.reloadCity = ->
      $scope.ngModel.city = ""
      $scope.addressCheck()

    $scope.countryWidth = ->
      if $scope.showStreet is "true"
        'col-sm-3'
      else
        if $scope.showCity is "true"
          'col-sm-4'
        else
          'col-sm-6'

    $scope.provinceWidth = ->
      if $scope.showStreet is "true"
        'col-sm-3'
      else
        if $scope.showCountry is "true" and $scope.showCity is "true"
          'col-sm-4'
        else
          'col-sm-6'

    $scope.cityWidth = ->
      if $scope.showStreet is "true"
        'col-sm-3'
      else
        if $scope.showCountry is "true"
          'col-sm-4'
        else
          'col-sm-6'

    $scope.$watch 'ngModel.province', (nv) ->
      $scope.initCitys()
    return
  ]

.directive 'address', [ 'addressConfig', (addressConfig) ->
  restrict : 'E'
  require  : '?ngModel'
  scope    :
    ngModel        : '='
    requireInvalid : '='
  controller  : 'AddressController'
  templateUrl : 'address.html'
  link        : (scope, element, attr, ctrl) ->
    scope.initProvinces()
    scope.formName        = attr.formName || 'form'
    scope.name            = attr.name || 'address'
    scope.showCountry     = attr.showCountry || 'true'
    scope.showCity        = attr.showCity || 'true'
    scope.showStreet      = attr.showStreet || 'true'
    scope.inputMode       = attr.inputMode || 'select'

    attr.$observe 'provinceRequired', ->
      scope.provinceRequired = 'true'

    attr.$observe 'cityRequired', ->
      scope.cityRequired = 'true'

    attr.$observe 'streetRequired', ->
      scope.streetRequired = 'true'

    attr.$observe 'countries', ->
      scope.countries = JSON.parse(attr.countries) if attr.countries?
    scope.countries = addressConfig.countries if !scope.countries

]

angular.module 'ui.address.html', []
.run [
  '$templateCache'
  ($templateCache) ->
    $templateCache.put(
      'address.html',
      """
      <div ng-class="requireInvalid ? 'has-error' : ''">
        <div class="row">
          <div class="col-xs-4" ng-class="countryWidth()" ng-if="showCountry==='true'">
            <div class="select-wrapper">
              <select class="form-control" name="{{name + '_country'}}"
                ng-model="ngModel.country" ng-change="reloadAddress(ngModel.country)"
                ng-options="key as type for (key, type) in countries">
              </select>
            </div>
          </div>
          <div class="col-xs-4" ng-class="provinceWidth()">
            <div>
              <div class="select-wrapper" ng-if="ngModel.country==='CN' && inputMode==='select'">
                <select class="form-control" name="{{name + '_province'}}"
                  ng-model="ngModel.province" ng-change="reloadCity()"
                    ng-options="key as type for (key, type) in provinces">
                </select>
              </div>
              <div ng-if="inArray(['ZA','KR','CA','IT','UA','RU','ES','BY','TH'], ngModel.country)
              || (ngModel.country==='CN' && inputMode==='text')">
                <input type="text" class="form-control" name="{{name + '_province'}}"
                  ng-model="ngModel.province" placeholder="省" ng-change="addressCheck()">
              </div>
              <div ng-if="ngModel.country==='EG'">
                <input type="text" class="form-control" name="{{name + '_governorate'}}"
                  ng-model="ngModel.governorate" placeholder="省份" ng-change="addressCheck()">
              </div>
              <div ng-if="inArray(['GB','IE'], ngModel.country)">
                <input type="text" class="form-control" name="{{name + '_county'}}"
                  ng-model="ngModel.county" placeholder="郡" ng-change="addressCheck()">
              </div>
              <div ng-if="ngModel.country==='TW'">
                <input type="text" class="form-control" name="{{name + '_county'}}"
                  ng-model="ngModel.county" placeholder="县市" ng-change="addressCheck()">
              </div>
              <div ng-if="ngModel.country==='JP'">
                <input type="text" class="form-control" name="{{name + '_prefecture'}}"
                  ng-model="ngModel.prefecture" placeholder="都道府县" ng-change="addressCheck()">
              </div>
              <div ng-if="inArray(['US','AU','MY'], ngModel.country)">
                <input type="text" class="form-control" name="{{name + '_state'}}"
                  ng-model="ngModel.state" placeholder="州" ng-change="addressCheck()">
              </div>
              <div ng-if="inArray(['HK','MO'], ngModel.country)">
                <input type="text" class="form-control" name="{{name + '_region'}}"
                  ng-model="ngModel.region" placeholder="地区" ng-change="addressCheck()">
              </div>
              <div ng-if="!inArray(['CN','ZA','KR','CA','IT','UA','RU','ES','BY','TH','EG','GB','IE','TW','US','AU','MY','HK','MO','JP'], ngModel.country)">
                <input type="text" class="form-control" name="{{name + '_city'}}"
                  ng-model="ngModel.city" placeholder="城市" ng-change="addressCheck()">
              </div>
            </div>
          </div>
          <div class="col-xs-4" ng-class="cityWidth()" ng-if="showCity==='true'">
            <div>
              <div class="select-wrapper" ng-if="ngModel.country==='CN' && inputMode==='select'">
                <select class="form-control" name="{{name + '_city'}}"
                  ng-model="ngModel.city" ng-change="addressCheck()"
                  ng-options="key as type for (key, type) in citys">
                </select>
              </div>
              <div ng-if="inArray(['TH','PH','EG','HK'], ngModel.country)">
                <input type="text" class="form-control" name="{{name + '_district'}}"
                  ng-model="ngModel.district" placeholder="地区/分区" ng-change="addressCheck()">
              </div>
              <div ng-if="inArray(['NZ','AU'], ngModel.country)">
                <input type="text" class="form-control" name="{{name + '_suburb'}}"
                  ng-model="ngModel.suburb" placeholder="城区" ng-change="addressCheck()">
              </div>
              <div ng-if="ngModel.country==='JP'">
                <input type="text" class="form-control" name="{{name + '_country_city'}}"
                  ng-model="ngModel.country_city" placeholder="市区町村" ng-change="addressCheck()">
              </div>
              <div ng-if="ngModel.country==='TW'">
                <input type="text" class="form-control" name="{{name + '_township'}}"
                  ng-model="ngModel.township" placeholder="乡镇市区" ng-change="addressCheck()">
              </div>
              <div ng-if="inArray(['ZA','KR','CA','IT','UA','RU','ES','BY','MY','GB','IE','US','MO'],
                ngModel.country) || (ngModel.country==='CN' && inputMode==='text')">
                <input type="text" class="form-control" name="{{name + '_city'}}"
                  ng-model="ngModel.city" placeholder="城市" ng-change="addressCheck()">
              </div>
            </div>
          </div>
        </div>
        <div class="row" ng-if="showStreet==='true'">
          <div class="col-xs-12 col-is-6 col-sm-6 m-t-xs">
            <div ng-if="ngModel.country!=='JP'">
              <input type="text" class="form-control" name="{{name + '_street1'}}"
              ng-model="ngModel.street1" placeholder="街道" ng-change="addressCheck()">
            </div>
            <div ng-if="ngModel.country==='JP'">
              <input type="text" class="form-control" name="{{name + '_further_divisions1'}}"
              ng-model="ngModel.further_divisions1" placeholder="其它地址" ng-change="addressCheck()">
            </div>
          </div>
          <div class="col-xs-12 col-is-6 col-sm-6 m-t-xs">
            <div ng-if="ngModel.country!=='JP'">
              <input type="text" class="form-control" name="{{name + '_street2'}}"
              ng-model="ngModel.street2" placeholder="街道">
            </div>
            <div ng-if="ngModel.country==='JP'">
              <input type="text" class="form-control" name="{{name + '_further_divisions2'}}"
              ng-model="ngModel.further_divisions2" placeholder="其它地址">
            </div>
          </div>
        </div>
        <span ng-show="requireInvalid" class="help-block ng-cloak">
          此项不能为空
        </span>
      </div>
      """)
    return
]