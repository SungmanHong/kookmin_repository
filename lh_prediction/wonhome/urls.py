# -*- coding: utf-8 -*-
from django.conf.urls import url
from . import views

urlpatterns = [
    url(r'^$', views.IndexView.as_view(), name='won_index'),  # main index view 연결
    url(r'^results$', views.WonResultView.as_view(), name='won_result'),  # main index view 연결
]
