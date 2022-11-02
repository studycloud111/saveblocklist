mkdir -p -m 777 /usr/local/soga
rm -rf /usr/local/soga/geoip.dat
rm -rf /usr/local/soga/geosite.dat
rm -rf /usr/local/soga/*dns.json
wget -P /usr/local/soga https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
wget -P /usr/local/soga https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
wget -P /usr/local/soga https://raw.githubusercontent.com/studycloud111/saveblocklist/main/sgdns.json
wget -P /usr/local/soga https://raw.githubusercontent.com/studycloud111/saveblocklist/main/jpdns.json
wget -P /usr/local/soga https://raw.githubusercontent.com/studycloud111/saveblocklist/main/hkdns.json
    cat > /usr/local/soga/study.crt << EOF
-----BEGIN CERTIFICATE----- 
MIIGUTCCBTmgAwIBAgIMNet8/jw/4lKw9oEtMA0GCSqGSIb3DQEBCwUAMEwxCzAJ 
BgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSIwIAYDVQQDExlB 
bHBoYVNTTCBDQSAtIFNIQTI1NiAtIEcyMB4XDTIyMTAyMjEwNTAzMVoXDTIzMTEy 
MzEwNTAzMFowIDEeMBwGA1UEAwwVKi5zYW5rdWFpcWlhbnNoYW8uY29tMIIBIjAN 
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvnS1zPD5EMAjEPY6r3dwNC/NG6/Y 
W39RNffzjid3FxvdBV3dNgbLLXeU+oD45I+VD3KgvhsotssrWe//KymMfKXaa2xr 
gEH32c826cuh1PHtIDQjq1ibeBlLUhZsFWBgWLHpix/ekZ1780NhA4EpYITYe9/4 
yxOfEWk+6UMV5MGKfkEe0h1gPJa2ykxh4jGLygfl9i+aIb5I/2JNVYQbSZNJ/sRe 
/mxKSQbZqMq6xIZpxRItJnxS6ovI4HaZUqwd5ZnK94RyD3Ao2qmkxl72Om/WiR7s 
TYey8MV15xLLUznEg6x/BKXAag7A+ip3O31WzPMhMae2ozDDN7mrJW1WNQIDAQAB 
o4IDXTCCA1kwDgYDVR0PAQH/BAQDAgWgMIGKBggrBgEFBQcBAQR+MHwwQwYIKwYB 
BQUHMAKGN2h0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzYWxw 
aGFzaGEyZzJyMS5jcnQwNQYIKwYBBQUHMAGGKWh0dHA6Ly9vY3NwMi5nbG9iYWxz 
aWduLmNvbS9nc2FscGhhc2hhMmcyMFcGA1UdIARQME4wQgYKKwYBBAGgMgEKCjA0 
MDIGCCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0 
b3J5LzAIBgZngQwBAgEwCQYDVR0TBAIwADA/BgNVHR8EODA2MDSgMqAwhi5odHRw 
Oi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzYWxwaGFzaGEyZzIuY3JsMDUGA1Ud 
EQQuMCyCFSouc2Fua3VhaXFpYW5zaGFvLmNvbYITc2Fua3VhaXFpYW5zaGFvLmNv 
bTAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHwYDVR0jBBgwFoAU9c3V 
PAhQ+WpPOreX2laD5mnSaPcwHQYDVR0OBBYEFAaMVP1qDXE3HoLGuMFCQ+QyFjV1 
MIIBfQYKKwYBBAHWeQIEAgSCAW0EggFpAWcAdgCt9776fP8QyIudPZwePhhqtGcp 
Xc+xDCTKhYY069yCigAAAYP/UN5AAAAEAwBHMEUCIQCRV7WQI5cSa9cleFLsLO6T 
VEabbAx/LTLND/wxBHI4+QIgLCez5W8G4JSIk3EPFPHTe/jQRXkCQ9i6+h+xIRAm 
ZdAAdQBVgdTCFpA2AUrqC5tXPFPwwOQ4eHAlCBcvo6odBxPTDAAAAYP/UN4lAAAE 
AwBGMEQCIA9yThEsnz8K3KYSRFLj3u1KPUVKv1FG5BLSOCk0BLkoAiAOC0/Et3QA 
5/fcj4bijQcy1EsE/b8J5qjBuciZx5Sb2QB2ALNzdwfhhFD4Y4bWBancEQlKeS2x 
ZwwLh9zwAw55NqWaAAABg/9Q3isAAAQDAEcwRQIgbl+kOCgRpsSFy1X96BHHBX+s 
bGn3fKi9wDJ0yuluLnoCIQDV94ONgFyjHyO2ah4c76dwOMtV5iRzOI8MVl0Kt8ie 
fDANBgkqhkiG9w0BAQsFAAOCAQEAp5mxk/F0hSlE4kXOb/N38o+lhicUHaDjl21+ 
O8QSOAZvgD7NaTGIX6desq6Wzli+ggHxclf7w725vNo/5URPGhzMOFaR+FYdZwBn 
IsyBuOP4UnTC2lunjdeAUWjCNSdJd3BfG4/Ily3Zskm6Nex5uXG/jO57Gj7qd6Nl 
/kQg3xbBg79BXhzSWRmwjJvDK1qpL3IdFbOkuqX7MjmVIzia4MssgpDrTF2D6ShO 
RPXjAcjxKfdiG9tIMdsrk47Ab8U0xF4DS9rKkwnPHG2uyPEHVuy3yhooJbnvb/5U 
T/Uur4Q206/PAybVshtBIzTqZg+zeD5x9Dn6HA/OxJcyhl4ayg== 
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIETTCCAzWgAwIBAgILBAAAAAABRE7wNjEwDQYJKoZIhvcNAQELBQAwVzELMAkG
A1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jv
b3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xNDAyMjAxMDAw
MDBaFw0yNDAyMjAxMDAwMDBaMEwxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i
YWxTaWduIG52LXNhMSIwIAYDVQQDExlBbHBoYVNTTCBDQSAtIFNIQTI1NiAtIEcy
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2gHs5OxzYPt+j2q3xhfj
kmQy1KwA2aIPue3ua4qGypJn2XTXXUcCPI9A1p5tFM3D2ik5pw8FCmiiZhoexLKL
dljlq10dj0CzOYvvHoN9ItDjqQAu7FPPYhmFRChMwCfLew7sEGQAEKQFzKByvkFs
MVtI5LHsuSPrVU3QfWJKpbSlpFmFxSWRpv6mCZ8GEG2PgQxkQF5zAJrgLmWYVBAA
cJjI4e00X9icxw3A1iNZRfz+VXqG7pRgIvGu0eZVRvaZxRsIdF+ssGSEj4k4HKGn
kCFPAm694GFn1PhChw8K98kEbSqpL+9Cpd/do1PbmB6B+Zpye1reTz5/olig4het
ZwIDAQABo4IBIzCCAR8wDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8C
AQAwHQYDVR0OBBYEFPXN1TwIUPlqTzq3l9pWg+Zp0mj3MEUGA1UdIAQ+MDwwOgYE
VR0gADAyMDAGCCsGAQUFBwIBFiRodHRwczovL3d3dy5hbHBoYXNzbC5jb20vcmVw
b3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2NybC5nbG9iYWxzaWdu
Lm5ldC9yb290LmNybDA9BggrBgEFBQcBAQQxMC8wLQYIKwYBBQUHMAGGIWh0dHA6
Ly9vY3NwLmdsb2JhbHNpZ24uY29tL3Jvb3RyMTAfBgNVHSMEGDAWgBRge2YaRQ2X
yolQL30EzTSo//z9SzANBgkqhkiG9w0BAQsFAAOCAQEAYEBoFkfnFo3bXKFWKsv0
XJuwHqJL9csCP/gLofKnQtS3TOvjZoDzJUN4LhsXVgdSGMvRqOzm+3M+pGKMgLTS
xRJzo9P6Aji+Yz2EuJnB8br3n8NA0VgYU8Fi3a8YQn80TsVD1XGwMADH45CuP1eG
l87qDBKOInDjZqdUfy4oy9RU0LMeYmcI+Sfhy+NmuCQbiWqJRGXy2UzSWByMTsCV
odTvZy84IOgu/5ZR8LrYPZJwR2UcnnNytGAMXOLRc3bgr07i5TelRS+KIz6HxzDm
MTh89N1SyvNTBCVXVmaU6Avu5gMUTu79bZRknl7OedSyps9AsUSoPocZXun4IRZZ
Uw==
-----END CERTIFICATE-----
EOF
cat > /usr/local/soga/private.key << EOF
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC+dLXM8PkQwCMQ
9jqvd3A0L80br9hbf1E19/OOJ3cXG90FXd02Bsstd5T6gPjkj5UPcqC+Gyi2yytZ
7/8rKYx8pdprbGuAQffZzzbpy6HU8e0gNCOrWJt4GUtSFmwVYGBYsemLH96RnXvz
Q2EDgSlghNh73/jLE58RaT7pQxXkwYp+QR7SHWA8lrbKTGHiMYvKB+X2L5ohvkj/
Yk1VhBtJk0n+xF7+bEpJBtmoyrrEhmnFEi0mfFLqi8jgdplSrB3lmcr3hHIPcCja
qaTGXvY6b9aJHuxNh7LwxXXnEstTOcSDrH8EpcBqDsD6Knc7fVbM8yExp7ajMMM3
uaslbVY1AgMBAAECggEBAJfUxxIokQYvhkUBZut3VjXkXalS2DKpHv7dOob7I0+C
4QJkP/PQGq2WhWfm5YSgin6ULV0gnaaL9XVvhIbOSrccKTI2bsUC0ioLrYVY1xzB
+P4RUtZIfziRQaChS20HNge/XaWRtId1etkFwBNhJrFRdpvag6axb8AbnRGsb4m6
+CoxnAzsAW9Z9ToRPHK9byHLoXDMwuSkw02VNQp9TGvqrLqA41Tky8AjrEqCJp3K
hrD2k+krLagfJIwbkaPzlypBN4R8A908vubDDyw6lgKKSjcsWtoKpND84bjbZS3P
8vcKCddaTr8wDvGt/1AJIp6edFH7J5PFIt5t2nLQeUECgYEA7mli4dfXWj4tNd5i
lz9Mudob+l33qbeMVc1Nmyh7BsLlNHXiDYrStmsGXVFSsbtHtTk6H3nKBwwfr2bX
laBzDNLnPuYXf+pdXVk1QB27KQ26j44/i52vYkQh1x2wAjQeACHO3MgtfJcIgoed
YhVaUQh86dtCK0uL8/V53bPsGOkCgYEAzIGjGuQvPLWNuwjAdBgtpxsnjkdjijc3
4Q300HBtTtk34roPsShMNIA1/Y+UkRjDIKP2/zOYV6vU8biTD1c3TBkTQy29TW79
glVB/kEgNWtY0ADY/3YRYAhO0bUp1r9CzkFxcJBk/P5u+8VdUsebFh1cOPZNbd6u
cxCAfxc8A20CgYEAzVgJ6hmdC8Yn7JDpe/nyXNVGacOLsCs+fRyCblRUeoNdJW0v
UZizWpkd9zw3LIvw/F8Y98lPP/iqRcoff2meDnqM4DkQHoW++sr+OYYiEP8ZI9JS
Wy9qwwmJ2B1i3tMCz/xOjwz/WKNBmiOyY6ueidL0u/u0p1O/bFWPLGxuuxkCgYAS
D7D0AwsY9X/a8N7uYeRGSeOocS2dW1sYCT+B2SwONqj04THZl5GDYX9jMXcRiXpS
O6joyQm/VHGuF3sFc9JyahSFbli1qgPBqv31EpNhpGVnmWuQxECslo8/fhx/1sxz
otv98QK6RU5P9hJT6UUNIvKuJTKZbX1CtEZk8wxd0QKBgDV3l14ylUmdmHkoOkQv
O/Ja/UbLrcyk2jbHQjnEgVgkrUxipo8FvloPLUIrcwa+3LJPsjr22YFfKHCZH0WH
7Myi0B8sxcGp5BzjW1sqCwdqnk624RD6zWQJ6x1mmCbq7LRZIP/WPQeAW05Vnbj/
GlpAuNveUVQ5qu/UaSefowB5
-----END PRIVATE KEY-----
EOF
    cat > /usr/local/soga/blockList_xrayr << EOF
(api|ps|sv|offnavi|newvector|ulog\.imap|newloc)(\.map|)\.(baidu|n\.shifen)\.com
(.+\.|^)(360|so)\.(cn|com)
(.*\.||)(dafahao|minghui|dongtaiwang|epochtimes|ntdtv|falundafa|wujieliulan)\.(org|com|net)
(.*\.||)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|nytimes|dafahao|falundafa|minghui|falunaz|zhengjian|110.qq|mingjingnews|inmediahk|xinsheng|bannedbook|ntdtv|falungong|12321|secretchina|epochweekly|cn.rfi)\.(cn|com|org|net|club|net|fr|tw|hk)
(.*\.||)(mingjinglive|chinaaid|botanwang|xinsheng|rfi|breakgfw|chengmingmag|jinpianwang|xizang-zhiye|breakgfw|qi-gong|voachinese|mhradio|rfa|edoors|edoors|renminbao|soundofhope|zhengjian|dafahao|minghui|dongtaiwang|epochtimes|ntdtv|falundafa|wujieliulan|aboluowang|bannedbook|secretchina|dajiyuan|boxun|chinadigitaltimes|huaglad|dwnews|creaders|oneplusnews|rfa)\.(org|com|net|eu|info|me|fr)
(.*\.||)(metatrader4|metatrader5|mql5)\.(org|com|net)
EOF
    cat > /usr/local/soga/route.json << EOF
    {
    "domainStrategy": "IPOnDemand",
    "rules": [
        {
            "type": "field",
            "outboundTag": "block",
            "protocol": [
                "bittorrent"
            ]
        },
        {
        "type": "field",
        "outboundTag": "netflix_proxy",
        "domain": [
          "geosite:netflix"
            ]
        }
    ]
}
EOF
    cat > /usr/local/soga/custom_outbound.json << EOF
[
        {
        "tag": "netflix_proxy",
        "protocol": "http",
        "settings": {
         "servers": [
           {
             "address": "127.0.0.1",
             "port": 34567
           }
         ]
       }
     } 
    ]
EOF
    cat > /usr/local/soga/blockList << EOF
regexp:(api|ps|sv|offnavi|newvector|ulog\.imap|newloc)(\.map|)\.(baidu|n\.shifen)\.com
regexp:(.+\.|^)(360|so)\.(cn|com)
regexp:(.*\.||)(dafahao|minghui|dongtaiwang|epochtimes|ntdtv|falundafa|wujieliulan)\.(org|com|net)
regexp:(.*\.||)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|nytimes|dafahao|falundafa|minghui|falunaz|zhengjian|110.qq|mingjingnews|inmediahk|xinsheng|bannedbook|ntdtv|falungong|12321|secretchina|epochweekly|cn.rfi)\.(cn|com|org|net|club|net|fr|tw|hk)
regexp:(.*\.||)(mingjinglive|chinaaid|botanwang|xinsheng|rfi|breakgfw|chengmingmag|jinpianwang|xizang-zhiye|breakgfw|qi-gong|voachinese|mhradio|rfa|edoors|edoors|renminbao|soundofhope|zhengjian|dafahao|minghui|dongtaiwang|epochtimes|ntdtv|falundafa|wujieliulan|aboluowang|bannedbook|secretchina|dajiyuan|boxun|chinadigitaltimes|huaglad|dwnews|creaders|oneplusnews|rfa)\.(org|com|net|eu|info|me|fr)
regexp:(.*\.||)(metatrader4|metatrader5|mql5)\.(org|com|net)
EOF
