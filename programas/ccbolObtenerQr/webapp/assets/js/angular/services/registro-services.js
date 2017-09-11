var app = angular.module('ccbolApp.registroServices',[])

app.factory('registroServices', ['$http','$q','$rootScope', function($http,$q,$rootScope){
var  urlServer ="localhost"; 

	var self ={
		ciBarcode : function(datos){
					var d = $q.defer();
					console.log(datos);
                    $http({
                      method: 'GET',
						  url: 'http://localhost/ccbolAdmin/api/public/user/ciBarcode/'+datos
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
