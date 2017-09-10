var app = angular.module('ccbolApp.registroServices',[])

app.factory('registroServices', ['$http','$q','$rootScope', function($http,$q,$rootScope){
var  urlServer ="localhost"; 

	var self ={
		guardarEst : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'POST',
					  	url: 'http://'+urlServer+'/ccbolAdmin/api/public/user/adminLogin/',
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
		},
		getUserData : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'GET',
					  	url: 'http://'+urlServer+'/ccbolAdmin/api/public/user/listUserBc/'+datos
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
		},
		updateUserData : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'POST',
						  url: 'http://'+urlServer+'/ccbolAdmin/api/public/user/updateUser/',
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
		},
		loginUser : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                          method: 'POST',
						  url: 'http://'+urlServer+'/ccbolAdmin/api/public/user/adminLogin/',
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
		},	
		userPaidBc : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                          method: 'POST',
						  url: 'http://'+urlServer+'/ccbolAdmin/api/public/user/userPaidBc/',
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
		},	
		logOut : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'GET',
					  	url: 'http://'+urlServer+'/ccbolAdmin/api/public/user/logout/'+datos
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
