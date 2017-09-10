<?php
// DIC configuration

$container = $app->getContainer();

// view renderer
$container['renderer'] = function ($c) {
    $settings = $c->get('settings')['renderer'];
    return new Slim\Views\PhpRenderer($settings['template_path']);
};

// monolog
$container['logger'] = function ($c) {
    $settings = $c->get('settings')['logger'];
    $logger = new Monolog\Logger($settings['name']);
    $logger->pushProcessor(new Monolog\Processor\UidProcessor());
    $logger->pushHandler(new Monolog\Handler\StreamHandler($settings['path'], $settings['level']));
    return $logger;
};
//Database

$container['db_mysqli'] = function ($c) {
	$connectionString = $c->get('settings')['connectionString'];

	$mysqli = new mysqli($connectionString['host'], $connectionString['user'], $connectionString['pass'], $connectionString['name_db']);
	$mysqli->set_charset("utf8");
	return $mysqli;
};

// Models

$container['model']	= function($c){

	return (object)[
		'Event'	=>	new App\Model\EventModel($c->db_mysqli),
		'Expositor'	=>	new App\Model\ExpositorModel($c->db_mysqli),
		'Location'	=>	new App\Model\LocationModel($c->db_mysqli),
		'User'	=>	new App\Model\UserModel($c->db_mysqli)
	];
};



