var app = angular.module('ccbolApp.preinscripcionCtrl',[]);

app.controller('preinscripcionCtrl', ['$scope','$rootScope','$location','preincripcionServices',function($scope,$rootScope,$location,preincripcionServices,){

    $scope.loader = false;


    $scope.guardar = function(data,frmUser) {
        $scope.loader = true;
        preincripcionServices.guardarEst( data ).then(function(){
        $scope.dataResponse = preincripcionServices.response;
        $scope.loader = false;
        
        });

            console.log(data)
        
    };


}]) 
