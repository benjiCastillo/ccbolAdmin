var app = angular.module('ccbolApp.homeCtrl',[]);

app.controller('homeCtrl', ['$scope','preincripcionServices',function($scope,preincripcionServices){
    //animations
    setTimeout(function(){
        $('.img-port-slide').addClass('animated visible flipInX');
    },0);
    setTimeout(function(){
        $('.titulo-ccbol').addClass('animated visible fadeInDown');
    },600);
    setTimeout(function(){
        $('.sub-titulo').addClass('animated visible slideInUp');
    },1200);
    setTimeout(function(){
        $('.timer-container').addClass('animated visible bounceInUp');
    },1500);


    $scope.loader = false;


    $scope.guardar = function(data,frmUser) {
        preincripcionServices.guardarEst( data ).then(function(){
        $scope.dataResponse = preincripcionServices.response;
        console.log($scope.dataResponse);
        });

            console.log(data)
        
    };
    
}]) 
