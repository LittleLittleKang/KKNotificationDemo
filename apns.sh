#!/bin/bash

deviceToken=536ee41f2e2756c4c063db4b4ed7dc2ff431bf71a40eb1768797462119XXXXXX

authKey="/Users/kang/Desktop/AuthKey_C2L2B33XXX.p8"
authKeyId=C2L2B33XXX
teamId=PTLCDC9XXX
bundleId=com.Kang.KKNotificationDemo
endpoint=https://api.development.push.apple.com

# 注意: 在 payload里 不能加任何注释, 否则将会导致数据错误进而通知失败. 还有, 最后一个键值对可加可不加逗号.
# "media":{"type":"video", "url":"http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4"}
# "media":{"type":"image", "url":"https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png"}
read -r -d '' payload <<-'EOF'
{
    "aps" : {
        "category" : "CATEGORY3",
        "mutable-content" : 1,
        "alert" : {
            "title" : "KK title",
            "subtitle" : "KK subtitle",
            "body"  : "KK body"
        }
    },
    "media" : {
        "type" : "image",
        "url" : "https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png"
    }
}
EOF

# --------------------------------------------------------------------------

base64() {
   openssl base64 -e -A | tr -- '+/' '-_' | tr -d =
}

sign() {
   printf "$1" | openssl dgst -binary -sha256 -sign "$authKey" | base64
}

time=$(date +%s)
header=$(printf '{ "alg": "ES256", "kid": "%s" }' "$authKeyId" | base64)
claims=$(printf '{ "iss": "%s", "iat": %d }' "$teamId" "$time" | base64)
jwt="$header.$claims.$(sign $header.$claims)"

curl --verbose \
   --header "content-type: application/json" \
   --header "authorization: bearer $jwt" \
   --header "apns-topic: $bundleId" \
   --data "$payload" \
   $endpoint/3/device/$deviceToken
