$(document).ready(function(){
    /*activar barra de menu mobile*/
    $("#icon-menu").click(function(){
        if ( $('#menu-xs-sm').attr('data-active') == 'false' ) {
            $('#menu-xs-sm').css("left", "0px");
            $('#menu-xs-sm').attr("data-active","true");
        } else {
            $('#menu-xs-sm').css("left", "-200px");
            $('#menu-xs-sm').attr("data-active","false");
        }   
    });



    });
