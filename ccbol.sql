-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 03-09-2017 a las 16:00:16
-- Versión del servidor: 10.1.13-MariaDB
-- Versión de PHP: 7.0.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ccbol`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `adminLogin` (IN `_count` VARCHAR(50), IN `_password` VARCHAR(50))  BEGIN
DECLARE _id_admin INT;
	IF(SELECT EXISTS(SELECT * FROM admin WHERE count=_count AND password=_password))THEN
        SET _id_admin=(SELECT id FROM admin WHERE count=_count AND password=_password);
        INSERT INTO access_log(started_time, id_admin) values(LOCALTIME(), _id_admin);
        SELECT 'Datos correctos, Bienvenido' as respuesta, 'not' as error, _id_admin as id; 
		
    ELSE
		SELECT 'Credenciales inválidas' as respuesta, 'yes' as error;
    END IF;
END$$

CREATE DEFINER=`grupociencia`@`localhost` PROCEDURE `insertProfessional` (IN `_name` VARCHAR(50), IN `_last_name` VARCHAR(80), IN `_ci` VARCHAR(13), IN `_email` VARCHAR(50), IN `_city` VARCHAR(35), IN `_professional_degree` VARCHAR(75))  BEGIN
DECLARE _id_user INT;
	IF (SELECT EXISTS(SELECT * FROM user WHERE ci=_ci))THEN
		SELECT 'Ha ocurrido un error, el CI ya está registrado, revisa este dato porfavor.' AS respuesta, 'yes' AS error;
    ELSE
		IF (SELECT EXISTS(SELECT * FROM user WHERE email=_email))THEN
			SELECT 'Ha ocurrido un error, el email ya está registrado, revisa este dato porfavor.' AS respuesta, 'yes' AS error;
        ELSE
			INSERT INTO user(name, last_name, ci, email, city) VALUES(_name, _last_name, _ci, _email, _city);
			SET _id_user = (last_insert_id());
			INSERT INTO professional(id_user, professional_degree) VALUES(_id_user, _professional_degree);
			SELECT 'Registro exitoso' AS respuesta, 'not' AS error, (SELECT id FROM user WHERE id=@@identity) AS ci;
		END IF;
	END IF;
END$$

CREATE DEFINER=`grupociencia`@`localhost` PROCEDURE `insertStudent` (IN `_name` VARCHAR(50), IN `_last_name` VARCHAR(80), IN `_ci` VARCHAR(13), IN `_email` VARCHAR(50), IN `_city` VARCHAR(35), IN `_college` VARCHAR(75), IN `_career` VARCHAR(75))  BEGIN
DECLARE _id_user INT;
	IF (SELECT EXISTS(SELECT * FROM user WHERE ci=_ci))THEN
		SELECT 'Ha ocurrido un error, el CI ya está registrado, revisa este dato porfavor.' AS respuesta, 'yes' AS error;
    ELSE
		IF (SELECT EXISTS(SELECT * FROM user WHERE email=_email))THEN
			SELECT 'Ha ocurrido un error, el email ya está registrado, revisa este dato porfavor.' AS respuesta, 'yes' AS error;
        ELSE
			INSERT INTO user(name, last_name, ci, email, city) VALUES(_name, _last_name, _ci, _email, _city);
			SET _id_user = (last_insert_id());
			INSERT INTO student(id_user, college, career) VALUES(_id_user, _college, _career);
			SELECT 'Registro exitoso' AS respuesta, 'not' AS error, (SELECT id FROM user WHERE id=@@identity) AS ci;
		END IF;
	END IF;
END$$

CREATE DEFINER=`grupociencia`@`localhost` PROCEDURE `listEvent` ()  BEGIN
	IF(SELECT EXISTS(SELECT * FROM event))THEN
		SELECT ev.id, ev.title, ev.description, ev.date, ev.date, ev.start_time, ex.name, ex.last_name, ex.degree, lo.site, lo.venue FROM event ev INNER JOIN expositor ex ON ev.id_expositor=ex.id INNER JOIN location lo ON ev.id_location=lo.id;
		SELECT 'not' AS error;
    ELSE
		SELECT 'No existen Actividades' AS respuesta, 'yes' AS error; 
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listUserBc` (IN `_id_user` INT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			SELECT 'not' as error , 1 as type, u.name, u.last_name, u.ci, u.email, u.city, u.paid, s.college, s.career,u.id
            FROM user u INNER JOIN student s ON u.id=s.id_user WHERE u.id=_id_user;
		ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				SELECT 'not' as error, 0 as type, u.name, u.last_name, u.ci, u.email, u.city, u.paid, p.professional_degree, u.id
				FROM user u INNER JOIN professional p ON u.id=p.id_user WHERE u.id=_id_user;
            ELSE
				SELECT  'yes' as error, 'No se encontró el registro' as respuesta; 
            END IF;
        END IF;
    ELSE
		SELECT  'yes' as error, 'No se encontró el registro' as respuesta; 
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `logout` (IN `_id_admin` INT)  BEGIN
DECLARE _started_time TIMESTAMP;
	SET _started_time = (SELECT started_time FROM access_log WHERE id_admin=_id_admin LIMIT 1);
	UPDATE access_log SET finished_time=LOCALTIME() WHERE id_admin=_id_admin and started_time=_started_time;
    SELECT 'Sesión Finalizada' AS respuesta, 'not' as error;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateUser` (IN `_id_user` INT, IN `_id_admin` INT, IN `_name` VARCHAR(50), IN `_last_name` VARCHAR(80), IN `_ci` VARCHAR(13), IN `_email` VARCHAR(50), IN `_city` VARCHAR(35), IN `_career` VARCHAR(75), IN `_college` TEXT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			UPDATE user SET name=_name, last_name=_last_name, ci=_ci, email=_email, 
			city=_city, id_admin=_id_admin  WHERE id=_id_user;
			UPDATE student SET college = _college, career=_career WHERE id_user=_id_user;
			SELECT 'Registro actualizado correctamente' as respuesta, 'not' as error;
        ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				UPDATE user SET name=_name, last_name=_last_name, ci=_ci, email=_email, 
				city=_city, id_admin=_id_admin WHERE id=_id_user;
                UPDATE professional SET professional_degree=_career WHERE id_user=_id_user;
				SELECT 'Registro actualizado correctamente' as respuesta, 'not' as error;
            ELSE
				SELECT 'Error, no se encontró el registro' as respuesta, 'yes' as error; 
            END IF;
        END IF;
    ELSE
		SELECT 'Error, no se encontró el registro' as respuesta, 'yes' as error; 
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `userPaidBc` (IN `_id_user` INT, IN `_id_admin` INT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			UPDATE user SET paid=1, inscription_date=LOCALTIME(), id_admin=_id_admin WHERE id=_id_user;
            /*INSERT INTO inscription(id_admin, id_user) values(_id_admin, _id_user);*/
			SELECT u.name, u.last_name, u.ci, u.email, u.city, u.paid, s.college, s.career 
            FROM user u INNER JOIN student s ON u.id=s.id_user WHERE u.id=_id_user;
		ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				UPDATE user SET paid=1, inscription_date=LOCALTIME(), id_admin=_id_admin WHERE id=_id_user;
                /*INSERT INTO inscription(id_admin, id_user) values(_id_admin, _id_user);*/
				SELECT u.name, u.last_name, u.ci, u.email, u.city, u.paid, p.professional_degree
				FROM user u INNER JOIN professional p ON u.id=p.id_user WHERE u.id=_id_user;
            ELSE
				SELECT 'No se encontró el registro' as respuesta, 'yes' as error; 
            END IF;
        END IF;
    ELSE
		SELECT 'No se encontró el registro' as respuesta, 'yes' as error; 
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `access_log`
--

CREATE TABLE `access_log` (
  `id` int(11) NOT NULL,
  `started_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finished_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_admin` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `admin`
--

CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `last_name` varchar(75) NOT NULL,
  `count` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `admin`
--

INSERT INTO `admin` (`id`, `name`, `last_name`, `count`, `password`) VALUES
(1, 'Gerardo ', 'Garcia Verodia', 'cajero-1', 'cajero-1'),
(2, 'Maria ', 'Jimenez Suarez', 'cajero-2', 'cajero-2');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `event`
--

CREATE TABLE `event` (
  `id` int(11) NOT NULL,
  `title` varchar(75) COLLATE utf8_spanish_ci NOT NULL,
  `description` text COLLATE utf8_spanish_ci NOT NULL,
  `date` date NOT NULL,
  `start_time` time NOT NULL,
  `finish_time` time NOT NULL,
  `id_expositor` int(11) NOT NULL,
  `id_location` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `event`
--

INSERT INTO `event` (`id`, `title`, `description`, `date`, `start_time`, `finish_time`, `id_expositor`, `id_location`) VALUES
(1, 'asdaw', 'sdawdaáññññññ', '2017-08-17', '08:12:42', '15:09:16', 1, 1),
(2, 'asdaw', 'sdawdaáññññññ', '2017-08-17', '08:12:42', '15:09:16', 1, 1),
(3, 'aaaa', 'aaaa', '2017-08-24', '12:00:00', '18:00:00', 1, 1),
(4, 'aaaa', 'aaaa', '2017-08-24', '12:00:00', '18:00:00', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `expositor`
--

CREATE TABLE `expositor` (
  `id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `last_name` varchar(80) COLLATE utf8_spanish_ci NOT NULL,
  `degree` varchar(350) COLLATE utf8_spanish_ci NOT NULL,
  `company` varchar(80) COLLATE utf8_spanish_ci NOT NULL,
  `description` text COLLATE utf8_spanish_ci NOT NULL,
  `facebook` text COLLATE utf8_spanish_ci NOT NULL,
  `twitter` text COLLATE utf8_spanish_ci NOT NULL,
  `github` text COLLATE utf8_spanish_ci NOT NULL,
  `other` text COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `expositor`
--

INSERT INTO `expositor` (`id`, `name`, `last_name`, `degree`, `company`, `description`, `facebook`, `twitter`, `github`, `other`) VALUES
(1, 'asdaw', 'sdawfd', 'sadwd', 'asdawd', 'dadfasd', 'asdawdas', 'asdawd', 'asdawd', 'asdawda');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `location`
--

CREATE TABLE `location` (
  `id` int(11) NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `site` varchar(150) COLLATE utf8_spanish_ci NOT NULL,
  `venue` varchar(150) COLLATE utf8_spanish_ci NOT NULL,
  `description` text COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `location`
--

INSERT INTO `location` (`id`, `latitude`, `longitude`, `site`, `venue`, `description`) VALUES
(1, 21341324.1231, 1231240.55, 'asdawd', 'qwdqsd', 'sdawdas'),
(3, -19.0388805, -65.2464312, 'Hotel Austria', 'Av. Ostria Gutierrez (a unos pasos de terminal de buses)', ''),
(4, -19.0374518, -65.2558092, 'Residencial Los Angeles', 'Av. Jaime Mendoza #1802', ''),
(5, -19.0412569, -65.2523085, 'Residencial Chuquisaca', 'Av. Ostria Gutierrez #33', ''),
(6, -19.0407603, -65.2517302, 'Cecil Hostal', 'Av. Ostria Gutierrez #106', ''),
(7, -19.0450043, -65.2606108, 'Hostal Veracruz', 'Cale Ravelo #158', ''),
(8, -19.0446439, -65.2584726, 'Residencial Ciudad Blanca', 'Av. Hernando Siles #617', ''),
(9, -19.0447661, -65.2608098, 'Hostal Recoleta Sur', 'Calle Ravelo #205', ''),
(10, -19.0392275, -65.2475959, 'Residencial Gloria Sur', 'Av. Ostria Gutiérrez #438', ''),
(11, -19.0372625, -65.2555192, 'Hostal Paulista', 'Av. Jaime Mendoza #1844', ''),
(12, -19.0448446, -65.2585504, 'Hotel Krono''s', 'Av. Hernando Siles #660', ''),
(13, -19.0363713, -65.2571898, 'Sermal Hotel', 'Av. Jaime Mendoza #2030', ''),
(14, -19.046765, -65.2593497, 'Grand Hotel', 'Calle Aniceto Arce #61', ''),
(15, -19.0406766, -65.2507388, 'Hostal Valeria', 'Av. Ostria Gutiérrez', ''),
(16, -19.0448528, -65.2606444, 'Hostal Charcas', 'Calle Ravelo #62', ''),
(17, -19.0452305, -65.2602066, 'Hotel la Escondida', 'Calle Junín #445', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lodging`
--

CREATE TABLE `lodging` (
  `id_location` int(11) NOT NULL,
  `simple_price` int(11) NOT NULL,
  `double_price` int(11) NOT NULL,
  `triple_price` int(11) NOT NULL,
  `includes` text COLLATE utf8_spanish_ci NOT NULL,
  `telephone` varchar(12) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `lodging`
--

INSERT INTO `lodging` (`id_location`, `simple_price`, `double_price`, `triple_price`, `includes`, `telephone`) VALUES
(3, 70, 140, 210, '', '(4)64-54202'),
(4, 70, 60, 40, 'WIFI, TV', '(4)64-62516'),
(5, 40, 0, 0, '', '(4)64-54459'),
(6, 80, 160, 220, 'Desayuno incluido, WIFI', '(4)64-24658'),
(7, 40, 130, 180, '', '(4)64-51560'),
(8, 80, 0, 0, 'TV Cable', '(4)64-45656'),
(9, 120, 180, 240, 'Desayuno incluido, WIFI', '(4)64-54789'),
(10, 60, 0, 0, 'Ducha, TV Cable', '(4)64-52847'),
(11, 100, 0, 0, 'Desayuno incluido, TV Cable, Internet', '(4)64-41769'),
(12, 140, 220, 320, 'Desayuno incluido, TV Cable, WIFI', '(4)64-52492'),
(13, 90, 0, 240, 'Desayuno incluido', '(4)64-63996'),
(14, 160, 180, 270, '', '(4)64-52461'),
(15, 70, 140, 210, '', ''),
(16, 0, 40, 55, '40 para 4 personas, Baño compartido', ''),
(17, 160, 260, 0, 'Desayuno incluido, TV Cable, WIFI', '(4)64-35792');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `professional`
--

CREATE TABLE `professional` (
  `id_user` int(11) NOT NULL,
  `professional_degree` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `professional`
--

INSERT INTO `professional` (`id_user`, `professional_degree`) VALUES
(164, 'ING. Sistemas Informáticos'),
(169, 'INGENIERIA DE SISTEMAS'),
(172, 'Garchador'),
(173, 'INGENIERA DE SISTEMAS'),
(181, 'asdasdas'),
(187, ''),
(192, ''),
(203, 'Ing. de Sistemas'),
(217, 'ing. licenciado'),
(220, 'puto'),
(221, 'puto');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `student`
--

CREATE TABLE `student` (
  `id_user` int(11) NOT NULL,
  `college` text COLLATE utf8_spanish_ci NOT NULL,
  `career` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `student`
--

INSERT INTO `student` (`id_user`, `college`, `career`) VALUES
(132, '(UMSS) Universidad Mayor de San Simón', 'Ing. de Sistemas'),
(133, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(134, 'test', 'test'),
(135, 'test1', 'test1'),
(136, 'Test2', 'Test2'),
(137, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(138, '(UMSA) Universidad Mayor ', 'Ing.Informática'),
(139, '(UMSA) Universidad Mayor de San Andrés', 'Ingenieria de Sistemas Informáticos'),
(140, '(UCB) Universidad Católica Boliviana', 'Ing. de Sistemas'),
(141, '(UMSA) Universidad Mayor de San Andrés', 'Ing. de Sistemas Informaticos'),
(142, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(143, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(144, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(145, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(146, 'Mayor de San Andres', 'Ing.Informática'),
(147, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(148, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(149, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(150, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(151, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(152, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(153, '(UMSA) Universidad Mayor de San Andrés', 'informatica'),
(154, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing.Informática'),
(155, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(156, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing.Informática'),
(157, '(UAP) Universidad Amazónica de Pando', 'Ing. de Sistemas'),
(158, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(159, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(160, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(161, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(162, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(163, '(UMSA) Universidad Mayor de San Andrés', 'informatica'),
(165, 'Universidad Mayor de San Andres', 'Informatica'),
(166, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(167, '(UAP) Universidad Amazónica de Pando', 'Ing. de Sistemas'),
(168, 'Universidad Mayor de San Andres', 'Informatica'),
(170, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(171, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(174, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(175, '(UMSS) Universidad Mayor de San Simón', 'Ing. de Software'),
(176, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(177, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(178, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing.Informática'),
(179, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(180, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(182, '(UTO) Universidad Técnica de Oruro', 'Ing. de Sistemas'),
(183, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(184, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(185, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(186, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(188, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(189, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(190, 'Universidad Mayor de San Andres', 'Ing.Informática'),
(191, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(193, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(194, '(USFX) Universidad Mayor de San Francisco Xavier', 'ingenieria de sistemas'),
(195, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. Informatica'),
(196, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(197, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(198, '(USFA) Universidad Privada San Francisco de Asís', 'Ing. de Sistemas'),
(199, '(UAP) Universidad Amazónica de Pando', 'Ing. de Sistemas'),
(200, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(201, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(202, 'San Francisco Javier de Chuquisaca', 'Ingeniería en Sistemas'),
(204, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(205, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. En Redes y Telecomunicaciones'),
(206, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(207, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(208, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(209, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(210, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(211, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(212, '(UABJB) Universidad Autónoma del Beni José Ballivián', 'Ingeniera de sistemas'),
(213, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(214, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(215, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(216, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(218, '(UCB) Universidad Católica Boliviana', 'Ing. de Software'),
(219, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(222, 'putos ad', 'ing en vagancia'),
(223, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(224, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(225, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(226, '(UMSA) Universidad Mayor de San Andrés', 'informática'),
(227, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(228, '(UMSA) Universidad Mayor de San Andrés', 'Informatica');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `last_name` varchar(80) COLLATE utf8_spanish_ci NOT NULL,
  `ci` varchar(13) COLLATE utf8_spanish_ci NOT NULL,
  `email` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `city` varchar(35) COLLATE utf8_spanish_ci NOT NULL,
  `paid` tinyint(1) NOT NULL DEFAULT '0',
  `registration_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cargo` varchar(50) COLLATE utf8_spanish_ci NOT NULL DEFAULT 'PARTICIPANTE',
  `inscription_date` timestamp NULL DEFAULT NULL,
  `id_admin` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `name`, `last_name`, `ci`, `email`, `city`, `paid`, `registration_date`, `cargo`, `inscription_date`, `id_admin`) VALUES
(132, 'Jose Alex', 'Chirinos', '10679891', 'jose@gmail.com', 'Sucre', 0, '2017-08-14 19:03:19', 'PARTICIPANTE', NULL, 0),
(133, 'Anahi Denisse', 'Contreras Buenaverez', '9981069', 'anahi.denisse.buena@gmail.com', 'La Paz', 0, '2017-08-14 22:20:04', 'PARTICIPANTE', NULL, 0),
(137, 'Diana Vanessa', 'Silva Arando', '7071807 LP', 'dianavanessa.dvsa@gmail.com', 'La Paz', 0, '2017-08-15 00:18:35', 'PARTICIPANTE', NULL, 0),
(138, 'Alvaro ', 'Copa Copa', ' 6901086tj', 'alvaro@gmail.com', 'La Sucre', 0, '2017-08-15 00:42:42', 'PARTICIPANTE', NULL, 0),
(139, 'Jesus Juan Carlos', 'Maraza Vigabriel', '8321156', 'carlosmaraza@gmail.com', 'La Paz', 0, '2017-08-15 01:43:49', 'PARTICIPANTE', NULL, 0),
(140, 'Tatiana', 'Chumacero Garcia', '4763971', 'chumacerotatiana@gmail.com', 'La Paz', 0, '2017-08-15 01:47:33', 'PARTICIPANTE', NULL, 0),
(141, 'VICTOR ALEJANDRO', 'ALCON CONDORI', '6964035', 'v.alejandro.alcon.c@gmail.com', 'La Paz', 0, '2017-08-15 01:48:37', 'PARTICIPANTE', NULL, 0),
(142, 'Cristhian Mauricio', 'Flores Vargas', '8352041', 'flovarmau@gmail.com', 'La Paz', 0, '2017-08-15 01:59:16', 'PARTICIPANTE', NULL, 0),
(143, 'Pamela Sesi', 'Uruchi Condori', '6966987 LP', 'pamelauruchi1@gmail.com', 'La Paz', 0, '2017-08-15 02:00:15', 'PARTICIPANTE', NULL, 0),
(144, 'Marisabel', 'Condori Cano', '10928881 Lp', 'mari.17ymy@gmail.com', 'La Paz', 0, '2017-08-15 02:17:08', 'PARTICIPANTE', NULL, 0),
(145, 'Alejandro', 'Mancilla', '8359856', 'alejandro-mancilla@outlook.com', 'La Paz', 0, '2017-08-15 02:21:07', 'PARTICIPANTE', NULL, 0),
(146, 'Maribel Maritza', 'Calle Averanga', '9241807', 'maryel.2mary@gmail.com', 'La Paz', 0, '2017-08-15 02:55:37', 'PARTICIPANTE', NULL, 0),
(147, 'Miguel Demetrio', 'Oropeza Quisbert', '9879793', 'demetrio947@yahoo.es', 'La Paz', 0, '2017-08-15 02:56:49', 'PARTICIPANTE', NULL, 0),
(148, 'Roberto Ruslan', 'Chambi Matha', '8324915', 'roby.mat11@gmail.com', 'La Paz', 0, '2017-08-15 03:53:01', 'PARTICIPANTE', NULL, 0),
(149, 'Aleyda Verónica', 'Villa-Gómez Zuleta', '5676656', 'aleve.villagomez.zuleta.93@gmail.com', 'Tarija', 0, '2017-08-15 04:02:34', 'PARTICIPANTE', NULL, 0),
(150, 'Marco', 'Ordoñez', '6732337', 'mvladyom@gmail.com', 'La Paz', 0, '2017-08-15 04:04:14', 'PARTICIPANTE', NULL, 0),
(151, 'Neith', 'Cabrera Colque', '7055848', 'cabrera.ne.93@gmail.com', 'La Paz', 0, '2017-08-15 04:54:05', 'PARTICIPANTE', NULL, 0),
(152, 'Claudia', 'Yupanqui Aruni', '8386621', 'yaczoe@gmail.com', 'La Paz', 0, '2017-08-15 06:30:49', 'PARTICIPANTE', NULL, 0),
(153, 'Aldo Samuel', 'Carrasco Fernandez', '7066860', 'aldosamycarras@gmail.com', 'La Paz', 0, '2017-08-15 06:30:54', 'PARTICIPANTE', NULL, 0),
(154, 'Natalia', 'Oviedo Acosta', '7745114 SC', 'natalia_o_95@hotmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-15 09:31:08', 'PARTICIPANTE', NULL, 0),
(155, 'Indira Noemi', 'Poma Canaviri', '8304469', 'indirapoma_c@outlook.com', 'La Paz', 0, '2017-08-15 12:00:32', 'PARTICIPANTE', NULL, 0),
(156, 'Genaro Mauricio', 'Alvarez Orias', '8460428 LP', 'naroalvarez97@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-15 14:29:07', 'PARTICIPANTE', NULL, 0),
(157, 'Misael Elias', 'Zubieta Callizaya', '4218896', 'zubieta1090@gmail.com', 'Cobija', 0, '2017-08-15 15:01:12', 'PARTICIPANTE', NULL, 0),
(159, 'Luis', 'Quisbert Quisbert', '6992211', 'jose.luis.quisbert@gmail.com', 'La Paz', 0, '2017-08-15 15:06:40', 'PARTICIPANTE', NULL, 0),
(160, 'Alvaro', 'Perales Lopez', '4911089', 'aplotomamos@gmail.com', 'La Paz', 0, '2017-08-15 15:10:07', 'PARTICIPANTE', NULL, 0),
(161, 'Virginia', 'Mamani Cari', '8326617', 'vicky.cari.1410@gmail.com', 'La Paz', 0, '2017-08-15 15:14:35', 'PARTICIPANTE', NULL, 0),
(162, 'Roxana Reyna', 'Sanchez Falcon', '6964253', 'infdeus@gmail.com', 'La Paz', 0, '2017-08-15 15:23:48', 'PARTICIPANTE', NULL, 0),
(163, 'Kheyvit Arman', 'Paniagua Medina', '9899014', 'kheyvitoopaniagua@gmail.com', 'La Paz', 0, '2017-08-15 15:26:58', 'PARTICIPANTE', NULL, 0),
(164, 'Juan carlos', 'Gallardo Jiménez', '2637323 lp', 'jcgj.gallardo@gmail.com', 'Cobija', 0, '2017-08-15 15:28:00', 'PARTICIPANTE', NULL, 0),
(165, 'Pamela Evelin', 'Mamani Ulo', '7054649', 'eveseves123@hotmail.com', 'La Paz', 0, '2017-08-15 15:29:06', 'PARTICIPANTE', NULL, 0),
(166, 'KARIM MARISOL', 'CORI POMA', '10930367', 'karimmarisolcoripoma@gmail.com', 'La Paz', 0, '2017-08-15 15:30:49', 'PARTICIPANTE', NULL, 0),
(167, 'Jimmy Luis', 'Laruta Villarreal', '4202641', 'jdme3902@gmail.com', 'Cobija', 0, '2017-08-15 15:32:14', 'PARTICIPANTE', NULL, 0),
(168, 'Agustin', 'Zepita Quispe', '8323815', 'zepas123@hotmail.com', 'La Paz', 0, '2017-08-15 15:32:49', 'PARTICIPANTE', NULL, 0),
(169, 'CINTIA FAVIOLA', 'RIVERO CHINCHE', '5713797', 'cfaviolarivero7@gmail.com', 'Cobija', 0, '2017-08-15 15:38:52', 'PARTICIPANTE', NULL, 0),
(170, 'Daniel Alejandro', 'Gutierrez Montaño', '6676790', 'dagmcisco@gmail.com', 'Sucre', 0, '2017-08-15 15:45:02', 'PARTICIPANTE', NULL, 0),
(171, 'Jhovanna Magaly', 'Aldunate Cruz', '7225576', 'aldunatejhovanna@gmail.com', 'Tarija', 0, '2017-08-15 15:46:07', 'PARTICIPANTE', NULL, 0),
(172, 'Hasta Cuando va a seguir', 'Robando el Ugri y la manga de vagos?', '323233', 'tuhermana@gmail.com', 'Sucre', 0, '2017-08-15 16:45:51', 'PARTICIPANTE', NULL, 0),
(173, 'GLADYS ROSSEMARY', 'ZAPATA LAYME', '4021762', 'glazapata@hotmail.com', 'Oruro', 0, '2017-08-15 17:03:01', 'PARTICIPANTE', NULL, 0),
(174, 'Jorge Miguel', 'Mamani Lima', '8315617', 'miquimao047@gmail.com', 'La Paz', 0, '2017-08-15 17:58:16', 'PARTICIPANTE', NULL, 0),
(175, 'aaaa', 'bbbb', '1234567', 'ejemplo@algo.com', 'San Ignacio de Velasco', 0, '2017-08-15 17:58:42', 'PARTICIPANTE', NULL, 0),
(176, 'Cesar Hugo', 'choque Gutiérrez', '12407319', 'ces.123.lin5@gmail.com', 'Potosí', 0, '2017-08-15 17:58:54', 'PARTICIPANTE', NULL, 0),
(177, 'Erwin', 'Méndez Mejía', '12517815', 'erwinXYZ1@gmail.com', 'Sucre', 0, '2017-08-15 18:06:20', 'PARTICIPANTE', NULL, 0),
(178, 'Polla', 'Loco 2', '21111111', 'oscaroscarlq@gmail.com', 'Sucre', 0, '2017-08-15 18:10:03', 'PARTICIPANTE', NULL, 0),
(179, 'YECID JUNIOR', 'VELASQUEZ FERREL', '9106240', 'velasquezyecid@gmail.com', 'La Paz', 0, '2017-08-15 19:00:16', 'PARTICIPANTE', NULL, 0),
(180, 'Adrian', 'Baldiviezo Colque', '9640451', 'baldiviezo.colque.adrian@gmail.com', 'Sucre', 0, '2017-08-15 19:41:45', 'PARTICIPANTE', NULL, 0),
(181, 'test', 'test apellodo', 'test ci', 'cimar.meneses@gmail.com', 'test Ciudad', 0, '2017-08-15 20:22:28', 'PARTICIPANTE', NULL, 0),
(182, 'Jose luis', 'Fernandez flores', '5757824', 'josefernandezflores83@gmail.com', 'Oruro', 0, '2017-08-15 20:54:54', 'PARTICIPANTE', NULL, 0),
(183, 'Lino Fernando', 'Villca Jaita', '10540930', 'linfer94@gmail.com', 'Sucre', 0, '2017-08-15 20:58:07', 'PARTICIPANTE', NULL, 0),
(184, 'Raúl', 'Ayllón Manrrique', '8536544', 'raul.ayllon.manrrique@gmail.com', 'Tarija', 0, '2017-08-15 21:00:10', 'PARTICIPANTE', NULL, 0),
(185, 'Carlos', 'Llanos Rodriguez', '7209948', 'carlosraiton@gmail.com', 'Tarija', 0, '2017-08-15 21:20:17', 'PARTICIPANTE', NULL, 0),
(186, 'Elvis Edson', 'Basilio Chambi', '10674508', 'elvis.2e3@gmail.com', 'Tarija', 0, '2017-08-15 21:21:19', 'PARTICIPANTE', NULL, 0),
(187, 'Ives Gabriel', 'Pereira Velasco', '5090593', 'ivespv@gmail.com', 'Potosi', 0, '2017-08-15 21:32:16', 'PARTICIPANTE', NULL, 0),
(188, 'Gudnar Rodrigo', 'Illanes Fernández', '8363750 LP', 'gudnarillanes@gmail.com', 'La Paz', 0, '2017-08-15 22:01:23', 'PARTICIPANTE', NULL, 0),
(189, 'Rocio', 'Chipana Luna', '6958285 LP.', 'rouss.zero@gmail.com', 'La Paz', 0, '2017-08-15 22:07:27', 'PARTICIPANTE', NULL, 0),
(190, 'Yoel', 'Villanueva Cabrera', '8357764', 'yvillanueva612@gmail.com', 'La Paz', 0, '2017-08-15 22:16:21', 'PARTICIPANTE', NULL, 0),
(191, 'Cristhian Kevin', 'Huanca Mollo', '6938184', 'cristhian.kevin.huanca.77@gmail.com', 'La Paz', 0, '2017-08-15 22:25:26', 'PARTICIPANTE', NULL, 0),
(192, 'David Ramiro', 'Zenteno Callisaya', '4854447', 'davidrdzc19@gmail.com', 'Cobija', 0, '2017-08-15 22:35:06', 'PARTICIPANTE', NULL, 0),
(193, 'Ayelen Claudia', 'Torres Choque', '14023092', 'clausaye190@gmail.com', 'Potosí', 0, '2017-08-15 22:58:52', 'PARTICIPANTE', NULL, 0),
(194, 'yessica', 'ortega vargas', '12367715', 'yessicaov4@gmail.com', 'Sucre', 0, '2017-08-15 23:08:03', 'PARTICIPANTE', NULL, 0),
(195, 'Dania Veronica', 'Ayarachi Gomez', '10477054', 'Daniagomez162@gmail.com', 'Potosi', 0, '2017-08-15 23:26:35', 'PARTICIPANTE', NULL, 0),
(196, 'David', 'Sullcani', '7017236', 'twanaq3100bx@gmail.com', 'La Paz', 0, '2017-08-15 23:35:43', 'PARTICIPANTE', NULL, 0),
(197, 'Annabel Carolina', 'Acarapi Cruz', '6940438', 'anniac0296@gmail.com', 'La Paz', 0, '2017-08-15 23:44:48', 'PARTICIPANTE', NULL, 0),
(198, 'Grace Minerva', 'Caballero Michel', '8595373', 'caballeromichelg@gmail.com', 'Potosi', 0, '2017-08-15 23:45:44', 'PARTICIPANTE', NULL, 0),
(199, 'Diego Ariel', 'Cortéz Fernández', '4210550 pdo', 'dcortezfer@gmail.com', 'Cobija', 0, '2017-08-16 00:04:16', 'PARTICIPANTE', NULL, 0),
(200, 'Williams Alejandro', 'Cruz Castro', '9140480', 'alescito113@gmail.com', 'La Paz', 0, '2017-08-16 00:54:08', 'PARTICIPANTE', NULL, 0),
(201, 'Jose Manuel', 'Jerez Viaña', '8583371', 'manueljosejv@gmail.com', 'Sucre', 0, '2017-08-16 01:40:59', 'PARTICIPANTE', NULL, 0),
(202, 'Luis Fernando', 'Rojas Arroyo', '7509786', 'rojasfernando443@gmail.com', 'Sucre', 0, '2017-08-16 03:13:14', 'PARTICIPANTE', NULL, 0),
(203, 'WINDS', 'ALVAREZ', '756420', 'windsoralvarezdavila@gmail.com', 'Sucre', 0, '2017-08-16 03:30:09', 'PARTICIPANTE', NULL, 0),
(204, 'Bryan Abad', 'Pérez Gonzáles', '7216830', 'perez1195_03@hotmail.com', 'Tarija', 0, '2017-08-16 03:43:15', 'PARTICIPANTE', NULL, 0),
(205, 'Luis Fernando', 'Tejerina Tejerina', '10832674', 'fernandotejerina8@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-16 03:46:56', 'PARTICIPANTE', NULL, 0),
(206, 'Edyth Ivon', 'Quispe Cala', '12667547', 'edit.leinknss7@gmail.com', 'La Paz', 0, '2017-08-16 14:11:37', 'PARTICIPANTE', NULL, 0),
(207, 'Maria Isabel', 'Huampo Laura', '11107398', 'marseonji@gmail.com', 'La Paz', 0, '2017-08-16 14:19:28', 'PARTICIPANTE', NULL, 0),
(208, 'Jose antonio', 'Rojas quispe', '12761177', 'jarq381@gmail.com', 'La Paz', 0, '2017-08-16 14:28:35', 'PARTICIPANTE', NULL, 0),
(209, 'Muriel Carla', 'Soto paredes', '8348910', 'carlita.soto.111@gmail.com', 'La Paz', 0, '2017-08-16 14:29:14', 'PARTICIPANTE', NULL, 0),
(210, 'emerson antonio', 'ibañez torrez', '9903437', 'emersonantonio666@gmail.com', 'la paz', 0, '2017-08-16 14:35:20', 'PARTICIPANTE', NULL, 0),
(211, 'FAVIO HERNAN', 'ACARAPI CALLISAYA', '8302760', 'Favian.acarapi@gmail.com', 'La Paz', 0, '2017-08-16 14:41:23', 'PARTICIPANTE', NULL, 0),
(212, 'Brian Angelo', 'Lopez Torrico', '7603596', 'angelo.lt.91@gmail.com', 'Trinidad', 0, '2017-08-16 15:22:11', 'PARTICIPANTE', NULL, 0),
(213, 'Mauricio Alvaro', 'Rodriguez Calliconde', '6942104', 'maurialvarorc@gmail.com', 'La Paz', 0, '2017-08-16 15:46:25', 'PARTICIPANTE', NULL, 0),
(214, 'Miguel Arturo', 'Colque Flores', '6813634', 'miguelcolquef@gmail.com', 'La Paz', 0, '2017-08-16 15:50:31', 'PARTICIPANTE', NULL, 0),
(215, 'Mishel Diana', 'Flores Urrutia', '10901297', 'mishelvision@gmail.com', 'La Paz', 0, '2017-08-16 16:16:59', 'PARTICIPANTE', NULL, 0),
(216, 'Luis', 'Bautista Baptista', '6688062', 'luisfarkas@gmail.com', 'Sucre', 0, '2017-08-16 16:23:03', 'PARTICIPANTE', NULL, 0),
(217, 'Luis 45', 'hijos de tu34', '76722332P', 'lkaslkd@gmks.cl', 'potosi', 0, '2017-08-16 16:27:14', 'PARTICIPANTE', NULL, 0),
(218, 'juan56', 'perez perez', '65124579', 'perez@gmial.com', 'La Paz', 0, '2017-08-16 16:31:19', 'PARTICIPANTE', NULL, 0),
(219, 'Juan', 'Perez Juarez', '75463534', 'eso@hotmail.com', 'Sucre', 0, '2017-08-16 16:31:31', 'PARTICIPANTE', NULL, 0),
(220, 'evo1', 'morales1', '111', 'puto@dhd.com', 'Sucre', 0, '2017-08-16 16:34:03', 'PARTICIPANTE', NULL, 0),
(221, 'evo1', 'morales1', '1111', 'puto@hd.com', 'Sucre', 0, '2017-08-16 16:36:07', 'PARTICIPANTE', NULL, 0),
(222, 'evo1', 'morales1', '444', 'asas@dia.com', 'sucrete', 0, '2017-08-16 16:40:45', 'PARTICIPANTE', NULL, 0),
(223, 'ivan eddy', 'consori fuentes', '11100893', 'ivaneddyfuentescondori@gmail.com', 'La Paz', 0, '2017-08-16 16:44:25', 'PARTICIPANTE', NULL, 0),
(224, 'Lenny Mariel', 'Diaz', '7571312', 'lennymariel.diaz@gmail.com', 'Sucre', 0, '2017-08-16 17:01:10', 'PARTICIPANTE', NULL, 0),
(225, 'Marcelo', 'Torrez Azuga', '9178348', 'elmac395@gmail.com', 'La paz', 0, '2017-08-16 17:22:24', 'PARTICIPANTE', NULL, 0),
(226, 'Juan Enrique Dempsey', 'Rivera Quisberth', '6870545', 'juane222333@gmail.com', 'La Paz', 0, '2017-08-16 17:26:00', 'PARTICIPANTE', NULL, 0),
(227, 'Mery Vanessa', 'Mamani Paco', '9202563', 'merypretty28@gmail.com', 'La Paz', 0, '2017-08-16 18:21:53', 'PARTICIPANTE', NULL, 0),
(228, 'Claudia', 'Mamani Chino', '9887059', 'claumch123@gmail.com', 'La Paz', 0, '2017-08-16 18:34:55', 'PARTICIPANTE', NULL, 0);

--
-- Disparadores `user`
--
DELIMITER $$
CREATE TRIGGER `delete_audit` AFTER DELETE ON `user` FOR EACH ROW INSERT INTO user_aud(id_user, name, last_name, ci, email, 
   city, paid, registration_date, cargo, id_admin, 
   inscription_date, operation) VALUES(OLD.id,OLD.name,OLD.last_name, OLD.ci,OLD.email,OLD.city,OLD.paid,OLD.registration_date,OLD.cargo,
   OLD.id_admin, OLD.inscription_date, 'DELETED')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_audit` AFTER INSERT ON `user` FOR EACH ROW INSERT INTO user_aud(id_user, name, last_name, ci, email, 
   city, paid, registration_date, cargo, id_admin, 
   inscription_date, operation) VALUES(NEW.id,NEW.name,NEW.last_name, NEW.ci,NEW.email,NEW.city,NEW.paid,NEW.registration_date,NEW.cargo,
   NEW.id_admin, NEW.inscription_date, 'INSERTED')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_audit` AFTER UPDATE ON `user` FOR EACH ROW INSERT INTO user_aud(id_user, name, last_name, ci, email, 
   city, paid, registration_date, cargo, id_admin, 
   inscription_date, operation) VALUES(OLD.id,OLD.name,OLD.last_name, OLD.ci,OLD.email,OLD.city,OLD.paid,OLD.registration_date,OLD.cargo,
   OLD.id_admin, OLD.inscription_date, 'UPDATED')
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_aud`
--

CREATE TABLE `user_aud` (
  `id` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `ci` varchar(13) NOT NULL,
  `email` varchar(50) NOT NULL,
  `city` varchar(35) NOT NULL,
  `paid` tinyint(1) NOT NULL,
  `registration_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `cargo` varchar(50) NOT NULL,
  `id_admin` int(11) NOT NULL,
  `inscription_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `operation` varchar(13) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `user_aud`
--

INSERT INTO `user_aud` (`id`, `id_user`, `name`, `last_name`, `ci`, `email`, `city`, `paid`, `registration_date`, `cargo`, `id_admin`, `inscription_date`, `operation`) VALUES
(0, 159, 'chu chu chu chu', 'Quisbert Quisbert', '6992211', 'jose.luis.quisbert@gmail.com', 'La Paz', 0, '2017-08-15 15:06:40', 'PARTICIPANTE', 0, '2017-09-02 07:35:23', 'UPDATED'),
(0, 159, 'chu chu chu chu', 'Quisbert Quisbert', '6992211', 'jose.luis.quisbert@gmail.com', 'La Paz', 0, '2017-08-15 15:06:40', 'PARTICIPANTE', 0, '2017-09-02 07:36:44', 'UPDATED'),
(0, 132, 'Jose', 'Chirinos', '10679891', 'jose@gmail.com', 'Sucre', 0, '2017-08-14 19:03:19', 'PARTICIPANTE', 0, '2017-09-02 07:37:56', 'UPDATED'),
(0, 134, 'test', 'test', 'test', 'test@gmail.com', 'test', 0, '2017-08-14 22:27:36', 'PARTICIPANTE', 0, '2017-09-03 03:02:19', 'DELETED'),
(0, 229, '11111', '11111', '12345', '12345', 'aaaa', 0, '2017-09-03 03:05:34', 'PARTICIPANTE', 0, '2017-09-08 04:00:00', 'INSERTED'),
(0, 230, '11111', '11111', '12345', '12345', 'aaaa', 0, '2017-09-03 03:05:36', 'PARTICIPANTE', 0, '2017-09-08 04:00:00', 'INSERTED'),
(0, 230, '11111', '11111', '12345', '12345', 'aaaa', 0, '2017-09-03 03:05:36', 'PARTICIPANTE', 0, '2017-09-08 04:00:00', 'DELETED'),
(0, 229, '11111', '11111', '12345', '12345', 'aaaa', 0, '2017-09-03 03:05:34', 'PARTICIPANTE', 0, '2017-09-08 04:00:00', 'DELETED');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `access_log`
--
ALTER TABLE `access_log`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `event`
--
ALTER TABLE `event`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `expositor`
--
ALTER TABLE `expositor`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `lodging`
--
ALTER TABLE `lodging`
  ADD PRIMARY KEY (`id_location`);

--
-- Indices de la tabla `professional`
--
ALTER TABLE `professional`
  ADD PRIMARY KEY (`id_user`);

--
-- Indices de la tabla `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`id_user`);

--
-- Indices de la tabla `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `access_log`
--
ALTER TABLE `access_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `event`
--
ALTER TABLE `event`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `expositor`
--
ALTER TABLE `expositor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `location`
--
ALTER TABLE `location`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=231;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
