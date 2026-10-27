from django.urls import path

from web.views import health, home

urlpatterns = [path("", home), path("health", health)]
