var app = angular.module('ccbolApp.preinscripcionServices',[])

app.factory('preinscripcionServices', ['$http','$q','$rootScope', function($http,$q,$rootScope){
var urlServer = 'localhost';
	var self ={
		guardarEst : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'POST',
					  	url: 'http://'+urlServer+'/ccbolAdmin/api/public/user/insertStudentLocal/',
 						data: datos
                    	})
                        .then(function successCallback(response) {

								self.response 	= response.data;
								return d.resolve()	
                            }, function errorCallback(response) {
								
								self.response 	= response.data
								return d.resolve();
                        });
                       return d.promise;	 
		},	
		guardarProf : function(datos){
					var d = $q.defer();
					console.log(datos);
                    $http({
                      method: 'POST',
			  		  url: 'http://'+urlServer+'/ccbolAdmin/api/public/user/insertProfessionalLocal/',
 						data: datos
                    	})
                        .then(function successCallback(response) {

								self.response 	= response.data;
								return d.resolve()	
                            }, function errorCallback(response) {
								
								self.response 	= response.data
								return d.resolve();
                        });
                       return d.promise;	 
		}
					
	}


	return self;
}])