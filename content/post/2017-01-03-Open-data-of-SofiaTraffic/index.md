+++
author = "Blagovest Petrov"
title = "Open data of SofiaTraffic"
date = "2017-01-03"

tags = [
    "API",
]
categories = [
    "Public Data",
]
+++ 

Quick post, first for 2017.
I got an Android car PC computer for Christmas and the hacking ideas began to appear.  

## ![bus](img/bus.gif)

Because most the buffer parkings near the Sofia subway stations are full from early in the morning, I always have to do a lot of maneuvers with the car. It would be great if the car PC warns me about the free places around 1km away from the parking every morning, based on the GPS. I tried to find something some usable open information about the parkings on internet but there is nothing except this application for Android: [София Паркинг](https://play.google.com/store/apps/details?id=bg.cgm.parkingboards&hl=bg). It's only showing the free places in some blue zone parkigs in the centre of Sofia. The application is usable but not suitable for 2-din car PC. So, it wasn't so hard to find from where it gets the data:

### `https://213.240.235.145/web-site-service/rest/parkingBoardsRequest/allFreePlaces`

The certificate of the page is expired but it's not a big deal. The application looks a bit unmaintained. The last update was in 2014. The page returns this JSON:

```json
{
	"parkingRes": [
		{
			"code": "1",
			"datetimeChecked": "2017-01-30 13:57:52",
			"freePlaces": "71"
		},
		{
			"code": "2",
			"datetimeChecked": "2017-01-30 13:57:52",
			"freePlaces": "FULL"
		},
		{
			"code": "3",
			"datetimeChecked": "2017-01-30 13:57:52",
			"freePlaces": "FULL"
		},
		{
			"code": "4",
			"datetimeChecked": "2017-01-30 13:57:52",
			"freePlaces": "2"
		},
		{
			"code": "5",
			"datetimeChecked": "2017-01-30 13:57:52",
			"freePlaces": "8"
		},
		{
			"code": "6",
			"datetimeChecked": "2017-01-30 13:57:52",
			"freePlaces": "12"
		}
	]
}
```

The codes refers to the following locations:

1. Храм-паметник Ал. Невски
2. пл. Княз Александър I
3. бул. П. Евтимий
4. пл. Народно събрание
5. ул. Гурко - Телефонна палата
6. бул. Ал. Стамболийски
