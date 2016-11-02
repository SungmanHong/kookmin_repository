from django.shortcuts import render
from imdae_project.models import LeaseData
# Create your views here.
def index(request):
	return render(request, 'imdae_project/index.html')