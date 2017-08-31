var app = angular.module('ccbolApp.homeCtrl',[]);

app.controller('homeCtrl', ['$scope','$location','registroServices',function($scope,$location,registroServices){
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
        $scope.loader = true;
        registroServices.guardarEst( data ).then(function(){
        $scope.loader = false;
        $scope.dataResponse = registroServices.response;
        // console.log($scope.dataResponse);
            if($scope.dataResponse.error == 'not'){
                $location.path('/registro-exitoso');
                frmUser.autoValidateFormOptions.resetForm();
            }
        });
        
    };
    
}]) 
