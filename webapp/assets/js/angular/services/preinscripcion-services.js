var app = angular.module('ccbolApp.preincripcionServices',[])

app.factory('preincripcionServices', ['$http','$q','$rootScope', function($http,$q,$rootScope){

	var self ={
		guardarEst : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'POST',
					  	url: 'http://192.168.1.5/ccbol/api/public/user/adminLogin/',
 						data: datos
                    	})
                        .then(function successCallback(response) {
								// console.log(response.data);
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