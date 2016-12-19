# -*- coding: utf-8 -*-
#
from django.conf.urls import url
from kmapps import views

urlpatterns = [
	url(r'^$', views.index, name='index'),	# main index view 연결
	url(r'^results/?', views.results, name='results'),	# main index view 연결
]