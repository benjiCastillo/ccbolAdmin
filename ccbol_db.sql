-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 03-09-2017 a las 18:46:59
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
			SELECT 'not' as error , 1 as type, u.name, u.last_name, u.ci, u.email, u.city, u.cargo, u.paid, s.college, s.career,u.id
            FROM user u INNER JOIN student s ON u.id=s.id_user WHERE u.id=_id_user;
		ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				SELECT 'not' as error, 0 as type, u.name, u.last_name, u.ci, u.email, u.city, u.cargo, u.paid, p.professional_degree, u.id
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateUser` (IN `_id_user` INT, IN `_id_admin` INT, IN `_name` VARCHAR(50), IN `_last_name` VARCHAR(80), IN `_ci` VARCHAR(13), IN `_email` VARCHAR(50), IN `_city` VARCHAR(35), IN `_cargo` VARCHAR(20), IN `_career` VARCHAR(75), IN `_college` TEXT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			UPDATE user SET name=_name, last_name=_last_name, ci=_ci, email=_email, 
			city=_city, cargo=_cargo, id_admin=_id_admin  WHERE id=_id_user;
			UPDATE student SET college = _college, career=_career WHERE id_user=_id_user;
			SELECT 'Registro de estudiante actualizado correctamente' as respuesta, 'not' as error;
        ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				UPDATE user SET name=_name, last_name=_last_name, ci=_ci, email=_email, 
				city=_city, cargo=_cargo, id_admin=_id_admin WHERE id=_id_user;
                UPDATE professional SET professional_degree=_career WHERE id_user=_id_user;
				SELECT 'Registro de profesional actualizado correctamente' as respuesta, 'not' as error;
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
(181, 'Lic. En Informatica'),
(187, 'Lic. Informatica'),
(192, 'Ingeniero en Sistemas Informaticos'),
(203, 'Ing. de Sistemas'),
(217, 'ing. licenciado'),
(220, 'puto'),
(221, 'puto'),
(282, 't2'),
(309, 'Ingenieria de Sistemas'),
(310, 'Ingeniero de Sistemas'),
(322, 'Ingeniero de Sistemas'),
(357, 'Licenciado en Matemática'),
(358, 'Ingeniero de Sistemas'),
(380, 'Lic. En Informatica'),
(409, 'Licenciada en Informatica'),
(473, 'ing sistemas'),
(495, 'Ingeniero de Sistemas'),
(500, 'test8'),
(502, 'test1@gmail.com'),
(503, 'test2'),
(505, 'test4'),
(507, 'test6'),
(539, 'Ingeniero en Sistemas'),
(540, 'P2'),
(616, 'Fotografo'),
(672, 'Ingeniería Informática'),
(726, 'test11');

--
-- Disparadores `professional`
--
DELIMITER $$
CREATE TRIGGER `delete_professional_audit` AFTER DELETE ON `professional` FOR EACH ROW INSERT INTO professional_aud(id_user, professional_degree, operation) VALUES(OLD.id_user, OLD.professional_degree, 'DELETED')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_professional_audit` AFTER INSERT ON `professional` FOR EACH ROW INSERT INTO professional(id_user, professional_degree, operation) VALUES(NEW.id_user, NEW.professional_degree, 'INSERTED')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_professional_audit` AFTER UPDATE ON `professional` FOR EACH ROW INSERT INTO professional_aud(id_user, professional_degree, operation) VALUES(OLD.id_user, OLD.professional_degree, 'UPDATED')
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `professional_aud`
--

CREATE TABLE `professional_aud` (
  `id` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `professional_degree` varchar(75) NOT NULL,
  `operation` varchar(13) NOT NULL,
  `date_op` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
(138, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(139, '(UMSA) Universidad Mayor de San Andrés', 'Ingenieria de Sistemas Informáticos'),
(140, '(UMSA) Universidad Mayor de San Andrés', 'Ing. de Sistemas'),
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
(178, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
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
(228, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(229, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(230, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(231, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(232, 'test', 'test'),
(233, 'test2', 'test2'),
(234, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(235, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(236, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(237, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(238, '(UMSA) Universidad Mayor de San Andrés', 'Infomática'),
(239, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(240, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ingeniería de sistemas'),
(241, '(UMSA) Universidad Mayor de San Andrés', 'INFORMATICA'),
(242, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(243, '(UMSA) Universidad Mayor de San Andrés', 'informática'),
(244, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(245, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(246, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(247, 'universidad autónoma del Beni', 'Ing. de Sistemas'),
(248, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(249, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(250, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(251, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(252, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(253, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(254, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(255, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(256, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(257, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(258, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(259, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(260, 'Universidad Mayor de San Andres', 'Ing.Informática'),
(261, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(262, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(263, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(264, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(265, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(266, '(UAP) Universidad Amazónica de Pando', 'Ingenieria de sistemas'),
(267, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(268, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(269, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(270, '(UMSA) Universidad Mayor de San Ahndrés', 'Ing.Informática'),
(271, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(272, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(273, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(274, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(275, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'ing. informática'),
(276, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(277, '(UMSA) Universidad Mayor de San Andrés', 'Ing. de Sistemas'),
(278, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(279, '(UMSA) Universidad Mayor de San Andrés', 'INFORMATICA'),
(280, '(UMSA) Universidad Mayor de San Andrés', 'INFORMATICA'),
(281, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(283, 't0', 't0'),
(284, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(285, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(286, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(287, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(288, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(289, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(290, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(291, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(292, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(293, 'Universidad Mayor de San Andres', 'Informatica'),
(294, 'Universidad Mayor de San Andres', 'Ing.Informática'),
(295, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(296, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(297, '(UMSA) Universidad Mayor de San Andrés', 'informatica'),
(298, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(299, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing informatica'),
(300, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(301, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(302, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(303, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing. informatica'),
(304, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(305, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(306, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(307, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(308, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(311, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(312, '(UMSA) Universidad Mayor de San Andrés', 'informatica'),
(313, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(314, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Telecomunicaciones'),
(315, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(316, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(317, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(318, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(319, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(320, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(321, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(323, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(324, 'Facultad Nacional de Ingeniería', 'Ingeniería de Sistemas'),
(325, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(326, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(327, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(328, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(329, '(UMSA) Universidad Mayor de San Andrés', 'INFORMATICA'),
(330, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(331, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(332, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(333, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(334, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(335, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(336, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(337, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(338, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(339, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing Informatica'),
(340, 'UMSA', 'informática'),
(341, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(342, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(343, '(UMSA) Universidad Mayor de San Andrés', 'INFORMÁTICA'),
(344, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(345, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(346, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(347, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(348, 'Universidad Mayor de San Andres', 'Informatica'),
(349, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(350, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing. de Sistemas'),
(351, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(352, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(353, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(354, '(UABJB) Universidad Autónoma del Beni José Ballivián', 'Ing. de Sistemas'),
(355, '(UMSA) Universidad Mayor de San Andrés', 'Ing. de Sistemas'),
(356, 'Universidad amazonica de pando', 'Ingenieria de sistemas'),
(359, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingeniería de sistemas'),
(360, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(361, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(362, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(363, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(364, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(365, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(366, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(367, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(368, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(369, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(370, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(371, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(372, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(373, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(374, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(375, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(376, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(377, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(378, 'Mayor de San Andres', 'Informatica'),
(379, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(381, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(382, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(383, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(384, 'u.a.j.m.s', 'ingenieria de sistemas'),
(385, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(386, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(387, 'Facultad Nacional de Ingenieria', 'Ingenieria de Sistemas'),
(388, 'Universidad Autonoma Juan Misael Saracho', 'Ingenieria Informatica'),
(389, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(390, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(391, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(392, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing. de Sistemas'),
(393, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(394, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(395, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(396, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(397, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(398, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing.Informática'),
(399, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(400, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(401, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(402, '(UBI) Universidad Boliviana de Informática', 'Ing. de Sistemas'),
(403, '(UBI) Universidad Boliviana de Informática', 'Ing. de Sistemas'),
(404, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(405, 'Universidad Mayor de San Andres', 'Informatica'),
(406, 'Universidad Mayor de San Andres', 'Informática'),
(407, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(408, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(410, '(UTO) Universidad Técnica de Oruro', 'Ing. de Sistemas'),
(411, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(412, '(UTO) Universidad Técnica de Oruro', 'Ing. de Sistemas'),
(413, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(414, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Telecomunicaciones'),
(415, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ingeniería Informática'),
(416, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(417, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(418, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(419, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(420, 'Uuu', 'Uuuu'),
(421, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(422, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(423, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(424, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(425, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(426, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(427, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(428, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing.Informática'),
(429, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(430, '(UMSA) Universidad Mayor de San Andrés', 'informática'),
(431, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(432, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(433, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(434, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(435, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(436, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(437, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(438, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(439, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(440, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(441, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(442, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(443, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(444, 'Mayor de San Andres', 'Informatica'),
(445, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(446, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(447, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(448, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(449, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(450, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(451, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(452, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(453, 'Mayor de San Andres', 'Ing.Informática'),
(454, '(UPDS) Universidad Privada Domingo Savio', 'Ing. de Sistemas'),
(455, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(456, '(UMSS) Universidad Mayor de San Simón', 'Ing. de Sistemas'),
(457, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(458, '(USFX) Universidad Mayor de San Francisco Xavier', ''),
(459, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(460, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(461, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(462, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(463, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(464, 'USFX', 'Ing. Diseño y anlmacion digital'),
(465, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(466, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(467, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(468, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(469, '(UTO) Universidad Técnica de Oruro', 'Ing. de Sistemas'),
(470, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(471, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(472, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(474, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(475, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(476, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(477, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(478, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingeniería en Telecomunicaciones'),
(479, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(480, 'Tomas frias', 'Ingenieria de sistemas'),
(481, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(482, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(483, '(UATF) Universidad Autónoma Tomás Frías', 'Ing Informatica'),
(484, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(485, '(UATF) Universidad Autónoma Tomás Frías', 'Ing Informatica'),
(486, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(487, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(488, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(489, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(490, 'San francisco xavier chuquisaca', 'Ing. de Sistemas'),
(491, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(492, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(493, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(494, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(496, 'test3', 'test3'),
(497, 'test4', 'test4'),
(498, 'test5', 'test5'),
(499, 'test7', 'test7'),
(501, 'test', 'test'),
(504, 'test3', 'test3'),
(506, 'test5', 'test5'),
(508, 'test7', 'test7'),
(509, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(510, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(511, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria De Sistemas'),
(512, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(513, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(514, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(515, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(516, '(UAJMS) Universidad Autónoma Juan Misael Saracho', 'Ing.Informática'),
(517, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(518, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing.Informática'),
(519, '(USFX) Universidad Mayor de San Francisco Xavier', 'informatica'),
(520, 'Universidad autónoma tomas frías', 'Ingeniería informática'),
(521, '(UMSA) Universidad Mayor de San Andrés', 'INFORMATICA'),
(522, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(523, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(524, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(525, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(526, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(527, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(528, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(529, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(530, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(531, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(532, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(533, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(534, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(535, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(536, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(537, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(538, 'P1', 'P1'),
(541, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(542, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(543, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(544, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(545, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(546, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingeniería de sistemas'),
(547, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(548, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingeniería de Sistemas'),
(549, 'Pollo', 'Pollo'),
(550, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(551, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(552, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(553, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(554, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(555, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(556, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(557, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(558, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(559, '(UMSS) Universidad Mayor de San Simón', 'Ing. de Sistemas'),
(560, '(UMSS) Universidad Mayor de San Simón', 'Ing.Informática'),
(561, '(UMSS) Universidad Mayor de San Simón', 'Ing. de Sistemas'),
(562, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(563, 'tomas frías', 'ingeniería de sistemas'),
(564, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(565, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(566, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(567, '(UMSA) Universidad Mayor de San Andrés', 'informatica'),
(568, 'asdfasdf', 'asdf'),
(569, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(570, '(UMSS) Universidad Mayor de San Simón', 'Ing. de Sistemas'),
(571, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(572, 'Univercidad Nacional Siglo xx', 'Ingenieria Informatica'),
(573, '(UAP) Universidad Amazónica de Pando', 'Ing. de Sistemas'),
(574, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(575, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(576, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(577, 'UNSXX', 'Ing.Informática'),
(578, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(579, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. Diseño y Animación Digital'),
(580, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(581, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(582, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(583, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(584, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(585, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(586, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(587, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(588, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(589, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing Diseño y Animación Digital'),
(590, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(591, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(592, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(593, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(594, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(595, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(596, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(597, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(598, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(599, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(600, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(601, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(602, '(UBI) Universidad Boliviana de Informática', 'Ing. de Sistemas'),
(603, '(UBI) Universidad Boliviana de Informática', 'Ing. de Sistemas'),
(604, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(605, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(606, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(607, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(608, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(609, '(UMSS) Universidad Mayor de San Simón', 'Ing.Informática'),
(610, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(611, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(612, '(UMSS) Universidad Mayor de San Simón', 'Ing.Informática'),
(613, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(614, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(615, 'Nose', 'Nose'),
(617, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(618, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(619, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(620, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(621, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(622, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(623, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(624, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(625, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(626, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(627, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(628, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(629, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(630, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(631, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria de Sitemas'),
(632, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(633, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria de Sitemas'),
(634, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(635, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing Diseño y Animación Digital'),
(636, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(637, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(638, '(UAP) Universidad Amazónica de Pando', 'Ing. Sistemas'),
(639, '(UATF) Universidad Autónoma Tomás Frías', 'Ingenieria Informatica'),
(640, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(641, 'Usfx', 'Ingeniería en Diseño y Animación Digital'),
(642, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(643, '(UATF) Universidad Autónoma Tomás Frías', 'ingenieria informatica'),
(644, '(UATF) Universidad Autónoma Tomás Frías', 'ingenieria informatica'),
(645, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(646, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria de sistemas'),
(647, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(648, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(649, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(650, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(651, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(652, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(653, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(654, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(655, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(656, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(657, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(658, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(659, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(660, 'universidad autónoma tomas frías', 'ingeniería informática'),
(661, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(662, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(663, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(664, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(665, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(666, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(667, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. En Diseño y animación digital'),
(668, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. En Diseño y animación digital'),
(669, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(670, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(671, 'Test10', 'Test10'),
(673, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(674, 'test11', 'test11'),
(675, '(USALESIANA) Universidad Salesiana de Bolivia', 'Informática'),
(676, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(677, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(678, 'Universidad mayor de san andres', 'Informatica'),
(679, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(680, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria de Sitemas'),
(681, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria de Sistemas'),
(682, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(683, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing.en telecomunicaciones'),
(684, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria de Sitemas'),
(685, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(686, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria de Sitemas'),
(687, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(688, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing.Informática'),
(689, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(690, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(691, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(692, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(693, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingeniería en telecomunicaciones'),
(694, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ingenieria en diseño y animación digital'),
(695, '(USFX) Universidad Mayor de San Francisco Xavier', 'Telecom'),
(696, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(697, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. Diseño y Animacion Digital'),
(698, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(699, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(700, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(701, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(702, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(703, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(704, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing de Sistemas'),
(705, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing de istemass'),
(706, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(707, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. En diseñor y animación digital'),
(708, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(709, '', 'Ing. de Sistemas'),
(710, '(UMSS) Universidad Mayor de San Simón', 'Ing. de Sistemas'),
(711, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(712, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(713, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Telecomunicaciones'),
(714, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(715, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(716, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. En redes y Telecomunicaciones'),
(717, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(718, '(UMSA) Universidad Mayor de San Andrés', 'informatica'),
(719, '(UMSA) Universidad Mayor de San Andrés', 'informatica'),
(720, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(721, '(UATF) Universidad Autónoma Tomás Frías', 'Ing.Informática'),
(722, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(723, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(724, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(725, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(727, 'test13', 'test13'),
(728, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(729, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(730, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(731, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(732, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Telecomunicaciones'),
(733, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(734, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(735, '(UMSA) Universidad Mayor de San Andrés', 'Informática'),
(736, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(737, '(UMSA) Universidad Mayor de San Andrés', 'INFORMATICA'),
(738, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(739, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(740, '(UMSA) Universidad Mayor de San Andrés', 'INFORMATICA'),
(741, '(UMSS) Universidad Mayor de San Simón', 'Ing. de Sistemas'),
(742, 'UNIVERSIDAD AUTÓNOMA TOMAS FRIAS', 'Ingeniería de Sistemas'),
(743, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(744, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(745, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(746, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(747, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(748, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. Diseño y Animacion Digital'),
(749, '(UMSA) Universidad Mayor de San Andrés', 'Ing.Informática'),
(750, '(UTO) Universidad Técnica de Oruro', 'Ingeniería Electrónica'),
(751, '(USFX) Universidad Mayor de San Francisco Xavier', 'ing.diseño animacion digital'),
(752, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(753, '(UNSXX) Universidad Nacional de Siglo XX', 'Ing.Informática'),
(754, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(755, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Telecomunicaciones'),
(756, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Sistemas'),
(757, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(758, 'Universidad San Francisco Xavier de Chuquisaca', 'Ingenieria de sistemas'),
(759, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas'),
(760, '(UMSA) Universidad Mayor de San Andrés', 'Informatica'),
(761, '(USFX) Universidad Mayor de San Francisco Xavier', 'Ing. de Telecomunicaciones'),
(762, '(UAGRM) Universidad Autónoma Gabriel René Moreno', 'Ing. de Sistemas'),
(763, '(UATF) Universidad Autónoma Tomás Frías', 'Ing. de Sistemas');

--
-- Disparadores `student`
--
DELIMITER $$
CREATE TRIGGER `delete_student_audit` AFTER DELETE ON `student` FOR EACH ROW INSERT INTO student_aud(id_user, college, career, operation) VALUES(OLD.id_user, OLD.college, OLD.career, 'DELETED')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_student_audit` AFTER INSERT ON `student` FOR EACH ROW INSERT INTO student_aud(id_user, college, career, operation) VALUES(NEW.id_user, NEW.college, NEW.career, 'INSERTED')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_student_audit` AFTER UPDATE ON `student` FOR EACH ROW INSERT INTO student_aud(id_user, college, career, operation) VALUES(OLD.id_user, OLD.college, OLD.career, 'UPDATED')
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `student_aud`
--

CREATE TABLE `student_aud` (
  `id` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `college` text NOT NULL,
  `career` varchar(75) NOT NULL,
  `operation` varchar(13) NOT NULL,
  `date_op` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `student_aud`
--

INSERT INTO `student_aud` (`id`, `id_user`, `college`, `career`, `operation`, `date_op`) VALUES
(1, 132, '', '11111', 'UPDATED', '2017-09-03 16:19:47'),
(2, 132, '', '11111', 'UPDATED', '2017-09-03 16:20:33'),
(3, 132, '', '11111', 'UPDATED', '2017-09-03 16:21:08'),
(4, 132, '', '11111', 'UPDATED', '2017-09-03 16:22:58'),
(5, 132, '', '11111', 'UPDATED', '2017-09-03 16:24:26'),
(6, 133, '(UMSA) Universidad Mayor de San Andrés', 'Informatica', 'UPDATED', '2017-09-03 16:25:42');

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
  `cargo` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `inscription_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `id_admin` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `name`, `last_name`, `ci`, `email`, `city`, `paid`, `registration_date`, `cargo`, `inscription_date`, `id_admin`) VALUES
(132, 'jose', 'chirinos', '1111555', '11111155', '1111', 0, '2017-08-14 19:03:19', 'participante', '0000-00-00 00:00:00', 1),
(133, 'jose', 'chirinos', '1111555', '11111155', '1111', 0, '2017-08-14 22:20:04', 'organizador', '0000-00-00 00:00:00', 1),
(137, 'Diana Vanessa', 'Silva Arando', '7071807 LP', 'dianavanessa.dvsa@gmail.com', 'La Paz', 0, '2017-08-15 00:18:35', 'participante', '0000-00-00 00:00:00', 0),
(138, 'Alvaro David', 'Copa', '6901086', 'copa730@gmail.com', 'La Paz', 0, '2017-08-15 00:42:42', 'participante', '0000-00-00 00:00:00', 0),
(139, 'Jesus Juan Carlos', 'Maraza Vigabriel', '8321156', 'carlosmaraza@gmail.com', 'La Paz', 0, '2017-08-15 01:43:49', 'participante', '0000-00-00 00:00:00', 0),
(140, 'Tatiana Germania', 'Chumacero Garcia', '4763971', 'chumacerotatiana@gmail.com', 'La Paz', 0, '2017-08-15 01:47:33', 'participante', '0000-00-00 00:00:00', 0),
(141, 'VICTOR ALEJANDRO', 'ALCON CONDORI', '6964035', 'v.alejandro.alcon.c@gmail.com', 'La Paz', 0, '2017-08-15 01:48:37', 'participante', '0000-00-00 00:00:00', 0),
(142, 'Cristhian Mauricio', 'Flores Vargas', '8352041', 'flovarmau@gmail.com', 'La Paz', 0, '2017-08-15 01:59:16', 'participante', '0000-00-00 00:00:00', 0),
(143, 'Pamela Sesi', 'Uruchi Condori', '6966987 LP', 'pamelauruchi1@gmail.com', 'La Paz', 0, '2017-08-15 02:00:15', 'participante', '0000-00-00 00:00:00', 0),
(144, 'Marisabel', 'Condori Cano', '10928881 Lp', 'mari.17ymy@gmail.com', 'La Paz', 0, '2017-08-15 02:17:08', 'participante', '0000-00-00 00:00:00', 0),
(145, 'Alejandro', 'Mancilla', '8359856', 'alejandro-mancilla@outlook.com', 'La Paz', 0, '2017-08-15 02:21:07', 'participante', '0000-00-00 00:00:00', 0),
(146, 'Maribel Maritza', 'Calle Averanga', '9241807', 'maryel.2mary@gmail.com', 'La Paz', 0, '2017-08-15 02:55:37', 'participante', '0000-00-00 00:00:00', 0),
(147, 'Miguel Demetrio', 'Oropeza Quisbert', '9879793', 'demetrio947@yahoo.es', 'La Paz', 0, '2017-08-15 02:56:49', 'participante', '0000-00-00 00:00:00', 0),
(148, 'Roberto Ruslan', 'Chambi Matha', '8324915', 'roby.mat11@gmail.com', 'La Paz', 0, '2017-08-15 03:53:01', 'participante', '0000-00-00 00:00:00', 0),
(149, 'Aleyda Verónica', 'Villa-Gómez Zuleta', '5676656', 'aleve.villagomez.zuleta.93@gmail.com', 'Tarija', 0, '2017-08-15 04:02:34', 'participante', '0000-00-00 00:00:00', 0),
(150, 'Marco Vladimir', 'Ordoñez Marca', '6732337', 'mvladyom@gmail.com', 'La Paz', 0, '2017-08-15 04:04:14', 'participante', '0000-00-00 00:00:00', 0),
(151, 'Neith', 'Cabrera Colque', '7055848', 'cabrera.ne.93@gmail.com', 'La Paz', 0, '2017-08-15 04:54:05', 'participante', '0000-00-00 00:00:00', 0),
(152, 'Claudia', 'Yupanqui Aruni', '8386621', 'yaczoe@gmail.com', 'La Paz', 0, '2017-08-15 06:30:49', 'participante', '0000-00-00 00:00:00', 0),
(153, 'Aldo Samuel', 'Carrasco Fernandez', '7066860', 'aldosamycarras@gmail.com', 'La Paz', 0, '2017-08-15 06:30:54', 'participante', '0000-00-00 00:00:00', 0),
(154, 'Natalia', 'Oviedo Acosta', '7745114 SC', 'natalia_o_95@hotmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-15 09:31:08', 'participante', '0000-00-00 00:00:00', 0),
(155, 'Indira Noemi', 'Poma Canaviri', '8304469', 'indirapoma_c@outlook.com', 'La Paz', 0, '2017-08-15 12:00:32', 'participante', '0000-00-00 00:00:00', 0),
(156, 'Genaro Mauricio', 'Alvarez Orias', '8460428 LP', 'naroalvarez97@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-15 14:29:07', 'participante', '0000-00-00 00:00:00', 0),
(157, 'Misael Elias', 'Zubieta Callizaya', '4218896', 'zubieta1090@gmail.com', 'Cobija', 0, '2017-08-15 15:01:12', 'participante', '0000-00-00 00:00:00', 0),
(158, 'Alvaro Ariel', 'Martínez Mancilla', '11109097', 'alvaro_dudutex@outlook.es', 'La Paz', 0, '2017-08-15 15:04:44', 'participante', '0000-00-00 00:00:00', 0),
(159, 'Jose Luis', 'Quisbert Quisbert', '6992211', 'jose.luis.quisbert@gmail.com', 'La Paz', 0, '2017-08-15 15:06:40', 'participante', '0000-00-00 00:00:00', 0),
(160, 'Alvaro', 'Perales Lopez', '4911089', 'aplotomamos@gmail.com', 'La Paz', 0, '2017-08-15 15:10:07', 'participante', '0000-00-00 00:00:00', 0),
(161, 'Virginia', 'Mamani Cari', '8326617', 'vicky.cari.1410@gmail.com', 'La Paz', 0, '2017-08-15 15:14:35', 'participante', '0000-00-00 00:00:00', 0),
(162, 'Roxana Reyna', 'Sanchez Falcon', '6964253', 'infdeus@gmail.com', 'La Paz', 0, '2017-08-15 15:23:48', 'participante', '0000-00-00 00:00:00', 0),
(163, 'Kheyvit Arman', 'Paniagua Medina', '9899014', 'kheyvitoopaniagua@gmail.com', 'La Paz', 0, '2017-08-15 15:26:58', 'participante', '0000-00-00 00:00:00', 0),
(164, 'Juan carlos', 'Gallardo Jiménez', '2637323 lp', 'jcgj.gallardo@gmail.com', 'Cobija', 0, '2017-08-15 15:28:00', 'participante', '0000-00-00 00:00:00', 0),
(165, 'Pamela Evelin', 'Mamani Ulo', '7054649', 'eveseves123@hotmail.com', 'La Paz', 0, '2017-08-15 15:29:06', 'participante', '0000-00-00 00:00:00', 0),
(166, 'KARIM MARISOL', 'CORI POMA', '10930367', 'karimmarisolcoripoma@gmail.com', 'La Paz', 0, '2017-08-15 15:30:49', 'participante', '0000-00-00 00:00:00', 0),
(167, 'Jimmy Luis', 'Laruta Villarreal', '4202641', 'jdme3902@gmail.com', 'Cobija', 0, '2017-08-15 15:32:14', 'participante', '0000-00-00 00:00:00', 0),
(168, 'Agustin', 'Zepita Quispe', '8323815', 'zepas123@hotmail.com', 'La Paz', 0, '2017-08-15 15:32:49', 'participante', '0000-00-00 00:00:00', 0),
(169, 'CINTIA FAVIOLA', 'RIVERO CHINCHE', '5713797', 'cfaviolarivero7@gmail.com', 'Cobija', 0, '2017-08-15 15:38:52', 'participante', '0000-00-00 00:00:00', 0),
(170, 'Daniel Alejandro', 'Gutierrez Montaño', '6676790', 'dagmcisco@gmail.com', 'Sucre', 0, '2017-08-15 15:45:02', 'participante', '0000-00-00 00:00:00', 0),
(171, 'Jhovanna Magaly', 'Aldunate Cruz', '7225576', 'aldunatejhovanna@gmail.com', 'Tarija', 0, '2017-08-15 15:46:07', 'participante', '0000-00-00 00:00:00', 0),
(172, 'Hasta Cuando va a seguir', 'Robando el Ugri y la manga de vagos?', '323233', 'tuhermana@gmail.com', 'Sucre', 0, '2017-08-15 16:45:51', 'participante', '0000-00-00 00:00:00', 0),
(173, 'GLADYS ROSSEMARY', 'ZAPATA LAYME', '4021762', 'glazapata@hotmail.com', 'Oruro', 0, '2017-08-15 17:03:01', 'participante', '0000-00-00 00:00:00', 0),
(174, 'Jorge Miguel', 'Mamani Lima', '8315617', 'miquimao047@gmail.com', 'La Paz', 0, '2017-08-15 17:58:16', 'participante', '0000-00-00 00:00:00', 0),
(175, 'aaaa', 'bbbb', '1234567', 'ejemplo@algo.com', 'San Ignacio de Velasco', 0, '2017-08-15 17:58:42', 'participante', '0000-00-00 00:00:00', 0),
(176, 'Cesar Hugo', 'choque Gutiérrez', '12407319', 'ces.123.lin5@gmail.com', 'Potosí', 0, '2017-08-15 17:58:54', 'participante', '0000-00-00 00:00:00', 0),
(177, 'Erwin', 'Méndez Mejía', '12517815', 'erwinXYZ1@gmail.com', 'Sucre', 0, '2017-08-15 18:06:20', 'participante', '0000-00-00 00:00:00', 0),
(178, 'Fabio Daniel', 'Choque Mamani', '6795129', 'oscaroscarlq@gmail.com', 'La Paz', 0, '2017-08-15 18:10:03', 'participante', '0000-00-00 00:00:00', 0),
(179, 'YECID JUNIOR', 'VELASQUEZ FERREL', '9106240', 'velasquezyecid@gmail.com', 'La Paz', 0, '2017-08-15 19:00:16', 'participante', '0000-00-00 00:00:00', 0),
(180, 'Adrian', 'Baldiviezo Colque', '9640451', 'baldiviezo.colque.adrian@gmail.com', 'Sucre', 0, '2017-08-15 19:41:45', 'participante', '0000-00-00 00:00:00', 0),
(181, 'Cimar Hernan', 'Meneses España', '5078369', 'cimar.meneses@gmail.com', 'Potosi', 0, '2017-08-15 20:22:28', 'participante', '0000-00-00 00:00:00', 0),
(182, 'Jose luis', 'Fernandez flores', '5757824', 'josefernandezflores83@gmail.com', 'Oruro', 0, '2017-08-15 20:54:54', 'participante', '0000-00-00 00:00:00', 0),
(183, 'Lino Fernando', 'Villca Jaita', '10540930', 'linfer94@gmail.com', 'Sucre', 0, '2017-08-15 20:58:07', 'participante', '0000-00-00 00:00:00', 0),
(184, 'Raúl', 'Ayllón Manrrique', '8536544', 'raul.ayllon.manrrique@gmail.com', 'Tarija', 0, '2017-08-15 21:00:10', 'participante', '0000-00-00 00:00:00', 0),
(185, 'Carlos', 'Llanos Rodriguez', '7209948', 'carlosraiton@gmail.com', 'Tarija', 0, '2017-08-15 21:20:17', 'participante', '0000-00-00 00:00:00', 0),
(186, 'Elvis Edson', 'Basilio Chambi', '10674508', 'elvis.2e3@gmail.com', 'Tarija', 0, '2017-08-15 21:21:19', 'participante', '0000-00-00 00:00:00', 0),
(187, 'Ives Gabriel', 'Pereira Velasco', '5090593', 'ivespv@gmail.com', 'Potosi', 0, '2017-08-15 21:32:16', 'participante', '0000-00-00 00:00:00', 0),
(188, 'Gudnar Rodrigo', 'Illanes Fernández', '8363750 LP', 'gudnarillanes@gmail.com', 'La Paz', 0, '2017-08-15 22:01:23', 'participante', '0000-00-00 00:00:00', 0),
(189, 'Rocio', 'Chipana Luna', '6958285 LP.', 'rouss.zero@gmail.com', 'La Paz', 0, '2017-08-15 22:07:27', 'participante', '0000-00-00 00:00:00', 0),
(190, 'Yoel', 'Villanueva Cabrera', '8357764', 'yvillanueva612@gmail.com', 'La Paz', 0, '2017-08-15 22:16:21', 'participante', '0000-00-00 00:00:00', 0),
(191, 'Cristhian Kevin', 'Huanca Mollo', '6938184', 'cristhian.kevin.huanca.77@gmail.com', 'La Paz', 0, '2017-08-15 22:25:26', 'participante', '0000-00-00 00:00:00', 0),
(192, 'David Ramiro', 'Zenteno Callisaya', '4854447', 'davidrdzc19@gmail.com', 'Cobija', 0, '2017-08-15 22:35:06', 'participante', '0000-00-00 00:00:00', 0),
(193, 'Ayelen Claudia', 'Torres Choque', '14023092', 'clausaye190@gmail.com', 'Potosí', 0, '2017-08-15 22:58:52', 'participante', '0000-00-00 00:00:00', 0),
(194, 'yessica', 'ortega vargas', '12367715', 'yessicaov4@gmail.com', 'Sucre', 0, '2017-08-15 23:08:03', 'participante', '0000-00-00 00:00:00', 0),
(195, 'Dania Veronica', 'Ayarachi Gomez', '10477054', 'Daniagomez162@gmail.com', 'Potosi', 0, '2017-08-15 23:26:35', 'participante', '0000-00-00 00:00:00', 0),
(196, 'David', 'Sullcani', '7017236', 'twanaq3100bx@gmail.com', 'La Paz', 0, '2017-08-15 23:35:43', 'participante', '0000-00-00 00:00:00', 0),
(197, 'Annabel Carolina', 'Acarapi Cruz', '6940438', 'anniac0296@gmail.com', 'La Paz', 0, '2017-08-15 23:44:48', 'participante', '0000-00-00 00:00:00', 0),
(198, 'Grace Minerva', 'Caballero Michel', '8595373', 'caballeromichelg@gmail.com', 'Potosi', 0, '2017-08-15 23:45:44', 'participante', '0000-00-00 00:00:00', 0),
(199, 'Diego Ariel', 'Cortéz Fernández', '4210550 pdo', 'dcortezfer@gmail.com', 'Cobija', 0, '2017-08-16 00:04:16', 'participante', '0000-00-00 00:00:00', 0),
(200, 'Williams Alejandro', 'Cruz Castro', '9140480', 'alescito113@gmail.com', 'La Paz', 0, '2017-08-16 00:54:08', 'participante', '0000-00-00 00:00:00', 0),
(201, 'Jose Manuel', 'Jerez Viaña', '8583371', 'manueljosejv@gmail.com', 'Sucre', 0, '2017-08-16 01:40:59', 'participante', '0000-00-00 00:00:00', 0),
(202, 'Luis Fernando', 'Rojas Arroyo', '7509786', 'rojasfernando443@gmail.com', 'Sucre', 0, '2017-08-16 03:13:14', 'participante', '0000-00-00 00:00:00', 0),
(203, 'WINDSOR', 'ALVAREZ DAVILA', '756420', 'windsoralvarezdavila@gmail.com', 'Sucre', 0, '2017-08-16 03:30:09', 'participante', '0000-00-00 00:00:00', 0),
(204, 'Bryan Abad', 'Pérez Gonzáles', '7216830', 'perez1195_03@hotmail.com', 'Tarija', 0, '2017-08-16 03:43:15', 'participante', '0000-00-00 00:00:00', 0),
(205, 'Luis Fernando', 'Tejerina Tejerina', '10832674', 'fernandotejerina8@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-16 03:46:56', 'participante', '0000-00-00 00:00:00', 0),
(206, 'Edyth Ivon', 'Quispe Cala', '12667547', 'edit.leinknss7@gmail.com', 'La Paz', 0, '2017-08-16 14:11:37', 'participante', '0000-00-00 00:00:00', 0),
(207, 'Maria Isabel', 'Huampo Laura', '11107398', 'marseonji@gmail.com', 'La Paz', 0, '2017-08-16 14:19:28', 'participante', '0000-00-00 00:00:00', 0),
(208, 'Jose antonio', 'Rojas quispe', '12761177', 'jarq381@gmail.com', 'La Paz', 0, '2017-08-16 14:28:35', 'participante', '0000-00-00 00:00:00', 0),
(209, 'Muriel Carla', 'Soto paredes', '8348910', 'carlita.soto.111@gmail.com', 'La Paz', 0, '2017-08-16 14:29:14', 'participante', '0000-00-00 00:00:00', 0),
(210, 'emerson antonio', 'ibañez torrez', '9903437', 'emersonantonio666@gmail.com', 'la paz', 0, '2017-08-16 14:35:20', 'participante', '0000-00-00 00:00:00', 0),
(211, 'FAVIO HERNAN', 'ACARAPI CALLISAYA', '8302760', 'Favian.acarapi@gmail.com', 'La Paz', 0, '2017-08-16 14:41:23', 'participante', '0000-00-00 00:00:00', 0),
(212, 'Brian Angelo', 'Lopez Torrico', '7603596', 'angelo.lt.91@gmail.com', 'Trinidad', 0, '2017-08-16 15:22:11', 'participante', '0000-00-00 00:00:00', 0),
(213, 'Mauricio Alvaro', 'Rodriguez Calliconde', '6942104', 'maurialvarorc@gmail.com', 'La Paz', 0, '2017-08-16 15:46:25', 'participante', '0000-00-00 00:00:00', 0),
(214, 'Miguel Arturo', 'Colque Flores', '6813634', 'miguelcolquef@gmail.com', 'La Paz', 0, '2017-08-16 15:50:31', 'participante', '0000-00-00 00:00:00', 0),
(215, 'Mishel Diana', 'Flores Urrutia', '10901297', 'mishelvision@gmail.com', 'La Paz', 0, '2017-08-16 16:16:59', 'participante', '0000-00-00 00:00:00', 0),
(216, 'Luis', 'Bautista Baptista', '6688062', 'luisfarkas@gmail.com', 'Sucre', 0, '2017-08-16 16:23:03', 'participante', '0000-00-00 00:00:00', 0),
(217, 'Luis 45', 'hijos de tu34', '76722332P', 'lkaslkd@gmks.cl', 'potosi', 0, '2017-08-16 16:27:14', 'participante', '0000-00-00 00:00:00', 0),
(218, 'juan56', 'perez perez', '65124579', 'perez@gmial.com', 'La Paz', 0, '2017-08-16 16:31:19', 'participante', '0000-00-00 00:00:00', 0),
(219, 'Juan', 'Perez Juarez', '75463534', 'eso@hotmail.com', 'Sucre', 0, '2017-08-16 16:31:31', 'participante', '0000-00-00 00:00:00', 0),
(220, 'evo1', 'morales1', '111', 'puto@dhd.com', 'Sucre', 0, '2017-08-16 16:34:03', 'participante', '0000-00-00 00:00:00', 0),
(221, 'evo1', 'morales1', '1111', 'puto@hd.com', 'Sucre', 0, '2017-08-16 16:36:07', 'participante', '0000-00-00 00:00:00', 0),
(222, 'evo1', 'morales1', '444', 'asas@dia.com', 'sucrete', 0, '2017-08-16 16:40:45', 'participante', '0000-00-00 00:00:00', 0),
(223, 'ivan eddy', 'consori fuentes', '11100893', 'ivaneddyfuentescondori@gmail.com', 'La Paz', 0, '2017-08-16 16:44:25', 'participante', '0000-00-00 00:00:00', 0),
(224, 'Lenny Mariel', 'Diaz', '7571312', 'lennymariel.diaz@gmail.com', 'Sucre', 0, '2017-08-16 17:01:10', 'participante', '0000-00-00 00:00:00', 0),
(225, 'Marcelo', 'Torrez Azuga', '9178348', 'elmac395@gmail.com', 'La paz', 0, '2017-08-16 17:22:24', 'participante', '0000-00-00 00:00:00', 0),
(226, 'Juan Enrique Dempsey', 'Rivera Quisberth', '6870545', 'juane222333@gmail.com', 'La Paz', 0, '2017-08-16 17:26:00', 'participante', '0000-00-00 00:00:00', 0),
(227, 'Mery Vanessa', 'Mamani Paco', '9202563', 'merypretty28@gmail.com', 'La Paz', 0, '2017-08-16 18:21:53', 'participante', '0000-00-00 00:00:00', 0),
(228, 'Claudia', 'Mamani Chino', '9887059', 'claumch123@gmail.com', 'La Paz', 0, '2017-08-16 18:34:55', 'participante', '0000-00-00 00:00:00', 0),
(229, 'Paolo Alejandro', 'Puita García', '8648626', 'stx._.06@live.com', 'Potosí', 0, '2017-08-16 19:21:30', 'participante', '0000-00-00 00:00:00', 0),
(230, 'Marco', 'Alachi', '10328112', 'marwenxd34@gmail.com', 'Sucre', 0, '2017-08-16 19:47:08', 'participante', '0000-00-00 00:00:00', 0),
(231, 'Erika Fatima', 'Perez Morales', '8300729', 'Erika.Fatima.PM@gmail.com', 'La Paz', 0, '2017-08-16 19:47:41', 'participante', '0000-00-00 00:00:00', 0),
(234, 'Franz Samuel', 'Cuevas Yañez', '6717765', 'sammyel794@gmail.com', 'Sucre', 0, '2017-08-16 21:23:29', 'participante', '0000-00-00 00:00:00', 0),
(235, 'Heidi Daiana', 'Lopez Zegarra', '12667651', 'heidivalove87@gmail.com', 'La Paz', 0, '2017-08-16 22:18:34', 'participante', '0000-00-00 00:00:00', 0),
(236, 'Carlos Oliver', 'Monrroy Arámbulo', '7224655', 'monrroy.sniper03@gmail.com', 'Tarija', 0, '2017-08-16 22:31:47', 'participante', '0000-00-00 00:00:00', 0),
(237, 'Giovanna Marisela', 'Soto Claros', '4891593 L.P.', 'angelrebelde_310@hotmail.com', 'La Paz', 0, '2017-08-17 00:17:40', 'participante', '0000-00-00 00:00:00', 0),
(238, 'Gabriela', 'Quilla Carrillo', '8369725', 'gaby17_q@hotmail.com', 'La Paz', 0, '2017-08-17 00:22:46', 'participante', '0000-00-00 00:00:00', 0),
(239, 'Favio Javier', 'Mollinedo Pacuanca', '9170991', 'faviomollinedo@gmail.com', 'La Paz', 0, '2017-08-17 01:47:59', 'participante', '0000-00-00 00:00:00', 0),
(240, 'EDSON RICHARD', 'FUNEZ HUANCA', '8197627', 'e.richardfunezh@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-17 01:52:53', 'participante', '0000-00-00 00:00:00', 0),
(241, 'MIJAIL ROMUALDO', 'MERCADO CALCINA', '6737389 LP', 'mija_merc@hotmail.com', 'La Paz', 0, '2017-08-17 02:10:12', 'participante', '0000-00-00 00:00:00', 0),
(242, 'Iván Aramís', 'Terrazas Paz', '6087794 LP', 'ivatepaz94@gmail.com', 'La Paz', 0, '2017-08-17 02:34:09', 'participante', '0000-00-00 00:00:00', 0),
(243, 'Josue Oscar', 'Espejo Quenta', '8343311 lp', 'josuestaqui@hotmail.com', 'La Paz', 0, '2017-08-17 03:21:00', 'participante', '0000-00-00 00:00:00', 0),
(244, 'Ludwig Alexander', 'Flores Flores', '4841214', 'f_f_lud@hotmail.com', 'La Paz', 0, '2017-08-17 03:28:34', 'participante', '0000-00-00 00:00:00', 0),
(245, 'Orbachs Kevin', 'Beltrán Rodríguez', '9127628', 'beltrankevin@gmail.com', 'La Paz', 0, '2017-08-17 04:54:08', 'participante', '0000-00-00 00:00:00', 0),
(246, 'wilver', 'vargas anagua', '10342024', 'kryshot05@gmail.com', 'Sucre', 0, '2017-08-17 13:53:18', 'participante', '0000-00-00 00:00:00', 0),
(247, 'juan carlos', 'miranda hinojosa', '7600689', 'juancmirandahinojosa@gmail.com', 'Beni', 0, '2017-08-17 14:13:52', 'participante', '0000-00-00 00:00:00', 0),
(248, 'Diego Orlando', 'Quispe Condori', '8264115', 'diego.2012.infognu@gmail.com', 'La Paz', 0, '2017-08-17 14:15:23', 'participante', '0000-00-00 00:00:00', 0),
(249, 'Lizeth Astrit', 'Altamirano Ramirez', '8685064 cbba', 'aslith27@gmail.com', 'La Paz', 0, '2017-08-17 15:15:12', 'participante', '0000-00-00 00:00:00', 0),
(250, 'Mikel', 'Alvarez bejarano', '5705104', 'mikel_ab-@hotmail.com', 'Sucre', 0, '2017-08-17 15:18:08', 'participante', '0000-00-00 00:00:00', 0),
(251, 'Maria Fernanda', 'López Terrazas', '5799282', 'mafer29594@gmail.com', 'Tarija', 0, '2017-08-17 15:37:12', 'participante', '0000-00-00 00:00:00', 0),
(252, 'Mauricio Daniel', 'Avalos Castellon', '5811139', 'mauromasterfifa201485@gmail.com', 'Tarija', 0, '2017-08-17 15:42:13', 'participante', '0000-00-00 00:00:00', 0),
(253, 'Oscar Rodrigo', 'Cahuaciri', '5788320', 'razzil.ryuk@gmail.com', 'Tarija', 0, '2017-08-17 15:42:59', 'participante', '0000-00-00 00:00:00', 0),
(254, 'Juan Pablo', 'Gonzales Alvarado', '7127215', 'juampi7237@gmail.com', 'Tarija', 0, '2017-08-17 15:53:14', 'participante', '0000-00-00 00:00:00', 0),
(255, 'MILENKA SHIRLEY', 'VICENTE QUISPE', '9103275', 'mile_cristal@hotmail.com', 'La Paz', 0, '2017-08-17 15:54:33', 'participante', '0000-00-00 00:00:00', 0),
(256, 'geovana carla', 'alapa condori', '8351469', 'gecarl.0812@gmail.com', 'La Paz', 0, '2017-08-17 16:03:03', 'participante', '0000-00-00 00:00:00', 0),
(257, 'Polet Chanel', 'Ayala Mamani', '7204980', 'saidcrishna@gmail.com', 'Tarija', 0, '2017-08-17 16:08:44', 'participante', '0000-00-00 00:00:00', 0),
(258, 'angela', 'Miranda flores', '6740666', 'angiejazminmiranda@gmail.com', 'La Paz', 0, '2017-08-17 16:17:02', 'participante', '0000-00-00 00:00:00', 0),
(259, 'PRIMO', 'LAURA CHOQUE', '6966635', 'primo.laura19@gmail.com', 'La Paz', 0, '2017-08-17 17:03:00', 'participante', '0000-00-00 00:00:00', 0),
(260, 'Mery Gabriela', 'Mamani Vallejos', '8287377', 'vallejosmerys501@gmail.com', 'La Paz', 0, '2017-08-17 17:12:59', 'participante', '0000-00-00 00:00:00', 0),
(261, 'David Max', 'Tito Andre', '10577712', 'david14nueve@gmail.com', 'Sucre', 0, '2017-08-17 17:16:56', 'participante', '0000-00-00 00:00:00', 0),
(262, 'Daniel Alejandro', 'Coronel Berrios', '6869952', 'danicobe31@gmail.com', 'La Paz', 0, '2017-08-17 17:18:59', 'participante', '0000-00-00 00:00:00', 0),
(263, 'Paola Romina', 'Catata Arce', '7103752', 'paocatata@gmail.com', 'Tarija', 0, '2017-08-17 18:13:54', 'participante', '0000-00-00 00:00:00', 0),
(264, 'Eleazar', 'Loayza Crespo', '4979539', 'leomar20rambito@gmail.com', 'La Paz', 0, '2017-08-17 18:43:34', 'participante', '0000-00-00 00:00:00', 0),
(265, 'Manuel Enrique', 'Barrenechea Flores', '12428403', 'barrenechea.mebf@gmail.com', 'Sucre', 0, '2017-08-17 19:01:31', 'participante', '0000-00-00 00:00:00', 0),
(266, 'Ricki Roy', 'Ribera Castedo', '12564469', 'rickyroyrivera@gmail.com', 'Cobija', 0, '2017-08-17 19:06:39', 'participante', '0000-00-00 00:00:00', 0),
(267, 'Herlan David', 'Poroma Alanoca', '8305464', 'enchantressherlan@gmail.com', 'La Paz', 0, '2017-08-17 20:29:07', 'participante', '0000-00-00 00:00:00', 0),
(268, 'Laura', 'Aguilar Escobar', '8442628', 'grylis.23@gmail.com', 'La Paz', 0, '2017-08-17 20:38:16', 'participante', '0000-00-00 00:00:00', 0),
(269, 'Sergio', 'Mora Gonzales', '7191178', 'serg.austin@gmail.com', 'Tarija', 0, '2017-08-17 20:44:07', 'participante', '0000-00-00 00:00:00', 0),
(270, 'Jhenny Zara', 'Huanca Ticona', '9213992 LP', 'jhenyfer.09990@gmail.com', 'La Paz', 0, '2017-08-17 20:46:53', 'participante', '0000-00-00 00:00:00', 0),
(271, 'Cristian Alejandro', 'Aguirre Ortiz', '7253217', 'Cristianalejandroaguirreortiz@gmail.com', 'Tarija', 0, '2017-08-17 20:55:30', 'participante', '0000-00-00 00:00:00', 0),
(272, 'Sergio Eduardo', 'Raya Vaca', '7521715', 'rick0_08@hotmail.com', 'Tarija', 0, '2017-08-17 21:04:31', 'participante', '0000-00-00 00:00:00', 0),
(273, 'Juan Jose', 'Angelo Serrudo', '10631180', 'jjangeloserrudo_@gmail.com', 'Tarija', 0, '2017-08-17 21:12:31', 'participante', '0000-00-00 00:00:00', 0),
(274, 'Gabriel', 'Aguilar Rodriguez', '7123789', 'gabo6252@gmail.com', 'Tarija', 0, '2017-08-17 21:39:33', 'participante', '0000-00-00 00:00:00', 0),
(275, 'Marleni Elizabeth', 'Sardina Baldiviezo', '7200203', 'marlene.elizabeth.sb94@gmail.com', 'Tarija', 0, '2017-08-17 21:52:48', 'participante', '0000-00-00 00:00:00', 0),
(276, 'jacqueline ninosca', 'hinojosa villegas', '8304382', 'jaquininosca@gmail.com', 'La Paz', 0, '2017-08-17 21:59:24', 'participante', '0000-00-00 00:00:00', 0),
(277, 'Mariluz', 'Vargas Hilari', '12514450', 'luzmar7.luz@gmail.com', 'La Paz', 0, '2017-08-17 22:03:10', 'participante', '0000-00-00 00:00:00', 0),
(278, 'Maria Karina', 'Limachi Yujra', '7061467', 'karina_amari@hotmail.com', 'La Paz', 0, '2017-08-17 22:06:25', 'participante', '0000-00-00 00:00:00', 0),
(279, 'KEYMI GABRIELA', 'RODRIGUEZ SANTA CRUZ', '9093350', 'rkeymi@gmail.com', 'La Paz', 0, '2017-08-17 22:56:34', 'participante', '0000-00-00 00:00:00', 0),
(280, 'BRAYAN EDIL', 'CRUZ INCA', '8444813', 'brayandelonge182@gmail.com', 'La Paz', 0, '2017-08-17 23:02:38', 'participante', '0000-00-00 00:00:00', 0),
(281, 'Ricardo', 'Saca Leon', '9632300', 'ricardo.sacaleon@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-18 00:03:53', 'participante', '0000-00-00 00:00:00', 0),
(282, 't2', 't2', 't2', 't2@gmail.com', 't2', 0, '2017-08-18 07:23:36', 'participante', '0000-00-00 00:00:00', 0),
(283, 't0', 't0', 't0', 't0@gmail.com', 't0', 0, '2017-08-18 07:28:45', 'participante', '0000-00-00 00:00:00', 0),
(284, 'Melissa Denisse', 'Conde Velasco', '8351420', 'denissemel47@gmail.com', 'La Paz', 0, '2017-08-18 12:46:20', 'participante', '0000-00-00 00:00:00', 0),
(285, 'Jhoselin Selene', 'Herrera Chinchero', '6996041', 'jhoselinseleneherrera@gmail.com', 'La Paz', 0, '2017-08-18 13:45:24', 'participante', '0000-00-00 00:00:00', 0),
(286, 'Marco Antonio', 'Altamirano Choque', '9201368 LP', 'altamiranomarco34@gmail.com', 'La Paz', 0, '2017-08-18 15:03:47', 'participante', '0000-00-00 00:00:00', 0),
(287, 'Milenka', 'Quispe Cayllante', '8343408', 'milenka.cr7@gmail.com', 'La Paz', 0, '2017-08-18 15:17:00', 'participante', '0000-00-00 00:00:00', 0),
(288, 'Fernando', 'Menodza Escobar', '9189645', 'ferchome0@gmail.com', 'La Paz', 0, '2017-08-18 15:32:13', 'participante', '0000-00-00 00:00:00', 0),
(289, 'Luis Alberto', 'Quenta Carvajal', '8320892', 'luchex54@gmail.com', 'La Paz', 0, '2017-08-18 15:37:23', 'participante', '0000-00-00 00:00:00', 0),
(290, 'Clisman', 'Duran Quispe', '9933451', 'clisduran123@gmail.com', 'La Paz', 0, '2017-08-18 15:56:07', 'participante', '0000-00-00 00:00:00', 0),
(291, 'Oscar Inti', 'Torrez Valdivia', '6945019', '111arafel111@gmail.com', 'La Paz', 0, '2017-08-18 16:41:24', 'participante', '0000-00-00 00:00:00', 0),
(292, 'Sergio Gary', 'Morga Liuca', '8321008 L.P.', 'morgan.gary.jet@gmail.com', 'La Paz', 0, '2017-08-18 17:41:34', 'participante', '0000-00-00 00:00:00', 0),
(293, 'Eber Edgar', 'Quenta Lopez', '9875596', 'eber.druidawow@gmail.com', 'La Paz', 0, '2017-08-18 18:41:09', 'participante', '0000-00-00 00:00:00', 0),
(294, 'Ramiro Maximiliano', 'Vargas Soliz', '6778970', 'ramirovargassape@hotmail.com', 'La Paz', 0, '2017-08-18 19:04:08', 'participante', '0000-00-00 00:00:00', 0),
(295, 'Cristian', 'Cárdenas Viveros', '10673641', 'cc77497954@gmail.com', 'Tarija', 0, '2017-08-18 20:40:43', 'participante', '0000-00-00 00:00:00', 0),
(296, 'Nilda Mariel', 'Quispe Machaca', '10912246', 'marielita.nil123@gmail.com', 'La Paz', 0, '2017-08-18 20:48:55', 'participante', '0000-00-00 00:00:00', 0),
(297, 'claudia yobana', 'cori sirpa', '8316705', 'yobanclaudia@gmil.com', 'La Paz', 0, '2017-08-18 20:52:12', 'participante', '0000-00-00 00:00:00', 0),
(298, 'Carlos Eduardo', 'Dorado Guerrero', '11400444 Sc.', 'carlitosdg007@gmail.com', 'Tarija', 0, '2017-08-18 20:52:56', 'participante', '0000-00-00 00:00:00', 0),
(299, 'Arnold', 'Arancibia Choque', '10673188', 'arnold753c@gmail.com', 'Tarija', 0, '2017-08-18 20:53:24', 'participante', '0000-00-00 00:00:00', 0),
(300, 'Alejandro Javier', 'Zeballos Aguilar', '7041679', 'ale03zeballos@gmail.com', 'La Paz', 0, '2017-08-18 20:58:29', 'participante', '0000-00-00 00:00:00', 0),
(301, 'Mirtha Fatima', 'Lozano Maraz', '10651416', 'fatilozano.17@gmail.com', 'Tarija', 0, '2017-08-18 21:01:09', 'participante', '0000-00-00 00:00:00', 0),
(302, 'Nilo Julio', 'Garcia Portales', '10650742', 'julio82865@gmail.com', 'Tarija', 0, '2017-08-18 21:01:17', 'participante', '0000-00-00 00:00:00', 0),
(303, 'Paula Talia', 'Flores Garnica', '7307736-1P', 'floreslia871@gmail.com', 'Tarija', 0, '2017-08-18 21:26:04', 'participante', '0000-00-00 00:00:00', 0),
(304, 'Kevin', 'Vargas Mantilla', '8433144', 'kredmercury@gmail.com', 'La Paz', 0, '2017-08-18 21:29:51', 'participante', '0000-00-00 00:00:00', 0),
(305, 'Gary Igor', 'Navia Velasco', '8323513', 'pegaso_gin@hotmail.com', 'LA PAZ', 0, '2017-08-18 21:53:05', 'participante', '0000-00-00 00:00:00', 0),
(306, 'José Carlos', 'Velasquez Rodriguez', '7198980', 'chaquejose@gmail.com', 'tarija', 0, '2017-08-18 22:32:37', 'participante', '0000-00-00 00:00:00', 0),
(307, 'Favio Lucas', 'Villalpando Mamani', '8563140', 'erenjaegger1@gmail.com', 'Tarija', 0, '2017-08-18 23:13:10', 'participante', '0000-00-00 00:00:00', 0),
(308, 'Paola Andrea', 'Poma Silva', '6989613', 'paolaandrea162011@gmail.com', 'La Paz', 0, '2017-08-18 23:22:34', 'participante', '0000-00-00 00:00:00', 0),
(309, 'Yeimy', 'Peña Maeda', '4212305', 'yeimy182011@gmail.com', 'Cobija', 0, '2017-08-19 00:20:56', 'participante', '0000-00-00 00:00:00', 0),
(310, 'Yosel', 'Justiniano Salvatierra', '4208453', 'justinianoyosel@gmail.com', 'Cobija', 0, '2017-08-19 00:24:17', 'participante', '0000-00-00 00:00:00', 0),
(311, 'Laura Veronica', 'Risueño Arancibia', '5795603', 'lauri.lro4@gmail.com', 'Sucre', 0, '2017-08-19 00:38:13', 'participante', '0000-00-00 00:00:00', 0),
(312, 'osmar', 'postigo vera', '9884529', 'osmar.postigo.vera@gmail.com', 'La Paz', 0, '2017-08-19 00:57:05', 'participante', '0000-00-00 00:00:00', 0),
(313, 'Elva Tereza', 'Cruz Rivera', '7199383', 'terezacr962@gmail.com', 'Tarija', 0, '2017-08-19 03:16:33', 'participante', '0000-00-00 00:00:00', 0),
(314, 'Kevin Julio', 'Salazar Castro', '9662774 sc', 'kjsc711@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-19 03:35:37', 'participante', '0000-00-00 00:00:00', 0),
(315, 'Franklin Yasser', 'Gonzales Ramos', '5094729', 'frarsf972@gmail.com', 'Tarija', 0, '2017-08-19 15:23:04', 'participante', '0000-00-00 00:00:00', 0),
(316, 'Ronal Adan', 'Torrejon Aparicio', '10740956', 'ronal123sd@gmail.com', 'Tarija', 0, '2017-08-19 17:48:48', 'participante', '0000-00-00 00:00:00', 0),
(317, 'Alex Herland', 'Perez Castillo', '5815494', 'alex_18pc@hotmail.com', 'Tarija', 0, '2017-08-19 20:24:12', 'participante', '0000-00-00 00:00:00', 0),
(318, 'Jaime', 'Alcaraz Jancko', '8511156', 'jhimi_cal16@hotmail.com', 'potosi', 0, '2017-08-19 23:36:22', 'participante', '0000-00-00 00:00:00', 0),
(319, 'Dania Daniela', 'Uruchi Quispe', '10926380', 'daniela-2321@hotmail.com', 'La Paz', 0, '2017-08-20 01:02:21', 'participante', '0000-00-00 00:00:00', 0),
(320, 'Omar Edgar', 'Callizaya calderon', '10069190', 'omaredgarcallizayacalderon@gmail.com', 'La paz', 0, '2017-08-20 01:13:05', 'participante', '0000-00-00 00:00:00', 0),
(321, 'Richard', 'Cuellar Rojas', '5282814', 'joserichard.intelectual@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-20 06:19:49', 'participante', '0000-00-00 00:00:00', 0),
(322, 'Esther', 'Zurita Condori', '5635816', 'esther.zurita.91@gmail.com', 'Sucre', 0, '2017-08-20 08:14:42', 'participante', '0000-00-00 00:00:00', 0),
(323, 'Mirtha Madelin', 'Serrano Renjifo', '7259808', 'madelin_159@hotmail.com', 'Tarija', 0, '2017-08-20 16:31:58', 'participante', '0000-00-00 00:00:00', 0),
(324, 'Marcela Susana', 'Rivera Ayala', '7296960', 'marcelitariveraayala@hotmail.com', 'Oruro', 0, '2017-08-20 18:35:34', 'participante', '0000-00-00 00:00:00', 0),
(325, 'Soraya Laura', 'Chuquimia Alejo', '8300696', 'esoraya1995@gmail.com', 'La Paz', 0, '2017-08-20 18:55:07', 'participante', '0000-00-00 00:00:00', 0),
(326, 'Daniel', 'Limache Serrano', '7256107', 'danielin_andres@hotmail.com', 'Tarija', 0, '2017-08-21 02:34:52', 'participante', '0000-00-00 00:00:00', 0),
(327, 'Angelica Tania', 'Leon Condori', '8353410', 'anghytanisq@gmail.com', 'La Paz', 0, '2017-08-21 03:27:27', 'participante', '0000-00-00 00:00:00', 0),
(328, 'Olga Benedicta', 'Oruño Flores', '7249395', 'olguitabof48@gmail.com', 'Tarija', 0, '2017-08-21 14:05:30', 'participante', '0000-00-00 00:00:00', 0),
(329, 'CINTHIA ALIZON', 'RIVEROS BALLON', '8441433', 'alizon-15@hotmail.com', 'La Paz', 0, '2017-08-21 14:17:02', 'participante', '0000-00-00 00:00:00', 0),
(330, 'Mayra', 'Bautista Arcani', '6957806', 'mayr_995@hotmail.com', 'La Paz', 0, '2017-08-21 14:43:15', 'participante', '0000-00-00 00:00:00', 0),
(331, 'Diego Hernán', 'Pérez Pereira', '6134063', 'jdhpp_perez@hotmail.com', 'La Paz', 0, '2017-08-21 14:50:54', 'participante', '0000-00-00 00:00:00', 0),
(332, 'amilcar', 'ortiz alarcón', '6784352', 'amilcar007latino@gmail.com', 'La Paz', 0, '2017-08-21 18:08:36', 'participante', '0000-00-00 00:00:00', 0),
(333, 'jhovanna luisa', 'davila tinta', '9915976', 'jholuisadavila@gmail.com', 'La Paz', 0, '2017-08-21 18:17:53', 'participante', '0000-00-00 00:00:00', 0),
(334, 'claudia alejandra', 'valero ledezma', '8484507', 'claudia_alexix12345@hotmail.com', 'La Paz', 0, '2017-08-21 18:40:38', 'participante', '0000-00-00 00:00:00', 0),
(335, 'Carlos tomas', 'Aguirre', '10621464', 'reyvin1994x@gmail.com', 'Tarija', 0, '2017-08-21 19:47:26', 'participante', '0000-00-00 00:00:00', 0),
(336, 'jonny alberto', 'herrera condori', '9939046', 'jonny_pocho@gmail.com', 'La Paz', 0, '2017-08-21 21:54:23', 'participante', '0000-00-00 00:00:00', 0),
(337, 'Reynaldo', 'Campos Reynaga', '5054753', 'reyinald82@gmail.com', 'Tarija', 0, '2017-08-21 21:55:15', 'participante', '0000-00-00 00:00:00', 0),
(338, 'Ulises Yamil', 'Posadas Alanez', '7180580', 'ulyss.19@gmail.com', 'Tarija', 0, '2017-08-21 22:20:59', 'participante', '0000-00-00 00:00:00', 0),
(339, 'Melina', 'Limachi Duran', '7177552', 'meli1316ld@gmail.com', 'Tarija', 0, '2017-08-21 23:01:29', 'participante', '0000-00-00 00:00:00', 0),
(340, 'Sebastián Fabian', 'Montes Mujica', '5977223', 'sefamol@gmail.com', 'La Paz', 0, '2017-08-22 02:52:21', 'participante', '0000-00-00 00:00:00', 0),
(341, 'Gabriela Karem', 'Casas Cornejo', '8341951', 'gabicita09.3@gmail.com', 'La Paz', 0, '2017-08-22 04:16:02', 'participante', '0000-00-00 00:00:00', 0),
(342, 'Carlos Fernando', 'Quisbert Maquera', '6768243', 'springscar108@gmail.com', 'La Paz', 0, '2017-08-22 04:32:00', 'participante', '0000-00-00 00:00:00', 0),
(343, 'Lissett Melinda', 'Humerez Cortez', '6054001', 'lissettmhcortez@gmail.com', 'La Paz', 0, '2017-08-22 11:40:52', 'participante', '0000-00-00 00:00:00', 0),
(344, 'Diego Gonzalo', 'Escalante Antezana', '12814942', 'diego.e.antezana1@gmail.com', 'Potosí', 0, '2017-08-22 13:01:03', 'participante', '0000-00-00 00:00:00', 0),
(345, 'Nilda', 'chambi Copali', '7236270-1G', 'adlin.nil.97@gmail.com', 'Tarija', 0, '2017-08-22 13:32:52', 'participante', '0000-00-00 00:00:00', 0),
(346, 'Rocio Pamela', 'Blanco Aguilar', '6730700', 'blagui77oz@gmail.com', 'La Paz', 0, '2017-08-22 13:53:53', 'participante', '0000-00-00 00:00:00', 0),
(347, 'Soledad Teresa', 'Nina Huanca', '8601234', 'soleni.13@gmail.com', 'Sucre', 0, '2017-08-22 14:36:29', 'participante', '0000-00-00 00:00:00', 0),
(348, 'Victor Hugo', 'Canaviri Lopez', '4913514LP', 'victord2exp@gmail.com', 'La Paz', 0, '2017-08-22 19:58:49', 'participante', '0000-00-00 00:00:00', 0),
(349, 'Manuel Alejandro', 'Garisto Zuna', '7545796', 'garistozunamanuel@gmail.com', 'Sucre', 0, '2017-08-22 22:33:24', 'participante', '0000-00-00 00:00:00', 0),
(350, 'Lizet Vianka', 'Romero Flores', '7119142', 'vianka.romero.06@gmail.com', 'Bermejo', 0, '2017-08-23 01:21:04', 'participante', '0000-00-00 00:00:00', 0),
(351, 'Gabriela Xiomara', 'Gallardo Flores', '6835428', 'ggflor@gmail.com', 'La Paz', 0, '2017-08-23 02:44:42', 'participante', '0000-00-00 00:00:00', 0),
(352, 'Victor Manuel', 'Oporto Betanzos', '7551043', 'vicoportob@gmail.com', 'Sucre', 0, '2017-08-23 03:40:41', 'participante', '0000-00-00 00:00:00', 0),
(353, 'Telassim Ginnola', 'Gomez Jimenez', '6822713', 'ginnolag@gmail.com', 'La Paz', 0, '2017-08-23 12:26:55', 'participante', '0000-00-00 00:00:00', 0),
(354, 'Wilfredo', 'moriba Guasase', '7598325', 'wilfredomoribaguasase@gmail.com', 'Trinidad', 0, '2017-08-23 13:07:56', 'participante', '0000-00-00 00:00:00', 0),
(355, 'Cristian Rodrigo', 'Chamby Salinas', '9112739', 'rodri07crisss@gmail.com', 'La Paz', 0, '2017-08-23 14:57:32', 'participante', '0000-00-00 00:00:00', 0),
(356, 'Oscar alexander', 'Perez hurtado', '5618378 bn', 'alexanders6666@gmail.com', 'Cobija', 0, '2017-08-23 15:46:22', 'participante', '0000-00-00 00:00:00', 0),
(357, 'Tiburcio', 'Coro Flores', '1382922', 'tcorof@hotmail.com', 'Potosí', 0, '2017-08-23 20:47:43', 'participante', '0000-00-00 00:00:00', 0),
(358, 'Alvaro', 'Alarcón Reynaga', '7470834', 'avery.alarcon@gmail.com', 'Sucre', 0, '2017-08-23 21:11:44', 'participante', '0000-00-00 00:00:00', 0),
(359, 'Ronal', 'Ortuño Barrero', '10306352', 'ronal001704@gmail.com', 'Sucre', 0, '2017-08-23 21:28:04', 'participante', '0000-00-00 00:00:00', 0),
(360, 'Luis Bryan', 'Cueva Parada', '13111820', 'luisbrian.lbcp@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-23 21:47:38', 'participante', '0000-00-00 00:00:00', 0),
(361, 'Elvis Cristhian', 'Callisaya Calle', '4751831', 'elvis.ec82@gmail.com', 'La Paz', 0, '2017-08-23 22:58:26', 'participante', '0000-00-00 00:00:00', 0),
(362, 'Paola Stefanie', 'Diaz Arriola', '8638463', 'paola.27.10.da@gmail.com', 'Potosí', 0, '2017-08-23 23:52:03', 'participante', '0000-00-00 00:00:00', 0),
(363, 'Elizabeth', 'Aduviri Zeballos', '6712854', 'eliadu90@gmail.com', 'Sucre', 0, '2017-08-24 00:23:46', 'participante', '0000-00-00 00:00:00', 0),
(364, 'Alan Walter', 'Machuca Durex', '3923229', 'alanwalter45@gmail.com', 'Sucre', 0, '2017-08-24 00:34:55', 'participante', '0000-00-00 00:00:00', 0),
(365, 'MIGUEL ANGEL', 'AGUIRRE VILLARROEL', '9974462', 'josemiguel151xv@gmail.com', 'La Paz', 0, '2017-08-24 01:20:38', 'participante', '0000-00-00 00:00:00', 0),
(366, 'Lisbeth', 'Fernandez Muruchi', '6711181', 'lafernan92@hotmail.com', 'Sucre', 0, '2017-08-24 13:09:59', 'participante', '0000-00-00 00:00:00', 0),
(367, 'Rene', 'Mamani Carvajal', '6186296', 'reneasjho16@gmail.com', 'La Paz', 0, '2017-08-24 16:06:35', 'participante', '0000-00-00 00:00:00', 0),
(368, 'GABRIEL', 'CONDORI TITTO', '7033038 LP', 'gabcontit123@gmail.com', 'La Paz', 0, '2017-08-24 18:18:23', 'participante', '0000-00-00 00:00:00', 0),
(369, 'Delia', 'Orellana Amaya', '7517958', 'orellana.amayadelia@gmail.com', 'Sucre', 0, '2017-08-24 18:44:53', 'participante', '0000-00-00 00:00:00', 0),
(370, 'Grover Luis', 'Alavi Murillo', '7032039', 'groveralavi@gmai.com', 'La Paz', 0, '2017-08-24 19:13:22', 'participante', '0000-00-00 00:00:00', 0),
(371, 'Blanca', 'Condori Mamani', '12363591 LP', 'blanquita.chiquit@gmail.com', 'La Paz', 0, '2017-08-24 21:42:38', 'participante', '0000-00-00 00:00:00', 0),
(372, 'Joel Benjamin', 'Gutierrez Mirabal', '10937176', 'yoisgutierrez8@gmail.com', 'La paz', 0, '2017-08-24 21:42:54', 'participante', '0000-00-00 00:00:00', 0),
(373, 'Cornelia', 'Mamani Marcani', '13219756', 'cornymamani12@gmail.com', 'Sucre', 0, '2017-08-24 21:43:29', 'participante', '0000-00-00 00:00:00', 0),
(374, 'Gabriela Arminda', 'Cruz', '7542677', 'ga1828244@gmail.com', 'Sucre', 0, '2017-08-24 21:58:46', 'participante', '0000-00-00 00:00:00', 0),
(375, 'Freddy', 'Condori Huanca', '6728517', 'freddyman61@gmail.com', 'La Paz', 0, '2017-08-24 22:14:22', 'participante', '0000-00-00 00:00:00', 0),
(376, 'Job Israel', 'Aruquipa Chavez', '8577103', 'israel.aruquipa.chavez@gmail.com', 'La Paz', 0, '2017-08-24 22:28:27', 'participante', '0000-00-00 00:00:00', 0),
(377, 'Maddizón Mashiel', 'Camacho Lugones', '8464476 L.P.', 'maddy.20.10.93@gmail.com', 'La Paz', 0, '2017-08-24 23:47:57', 'participante', '0000-00-00 00:00:00', 0),
(378, 'Evelyn Angela', 'Alanez Zenteno', '9101321', 'evesita18@gmail.com', 'La Paz', 0, '2017-08-25 00:09:48', 'participante', '0000-00-00 00:00:00', 0),
(379, 'Lorena Rocio', 'Zelada Perez', '8460805', 'lorenrocioz@gmail.com', 'La Paz', 0, '2017-08-25 02:14:30', 'participante', '0000-00-00 00:00:00', 0),
(380, 'Lenny Catherine', 'Sanabria Castellon', '3136200', 'lensanabria@yahoo.com', 'Cochabamba', 0, '2017-08-25 02:26:04', 'participante', '0000-00-00 00:00:00', 0),
(381, 'Reynel', 'Sanchez', '9124073', 'reynelsanchez70@gmail.com', 'La Paz', 0, '2017-08-25 03:55:10', 'participante', '0000-00-00 00:00:00', 0),
(382, 'MARCELO HUMBERTO', 'MURILLO TORRICO', '10337311', 'chelito.mm14@gmail.com', 'Sucre', 0, '2017-08-25 13:42:47', 'participante', '0000-00-00 00:00:00', 0),
(383, 'Javier Ramiro', 'Castillo Tarqui', '8353766', 'castilloramiro313@gmail.com', 'La Paz', 0, '2017-08-25 13:55:43', 'participante', '0000-00-00 00:00:00', 0),
(384, 'oscar', 'cruz', '7185153', 'racso_cruz23@hotmail.com', 'tarija_bermejo', 0, '2017-08-25 14:12:05', 'participante', '0000-00-00 00:00:00', 0),
(385, 'Kevin Edwin', 'Zanga Caero', '7246191', 'kevinzanga@gmail.com', 'Sucre', 0, '2017-08-25 14:23:44', 'participante', '0000-00-00 00:00:00', 0),
(386, 'Leandro Galo', 'Contreras Machaca', '9918645', 'leonc9ntreras010@gmail.com', 'La Paz', 0, '2017-08-25 14:34:52', 'participante', '0000-00-00 00:00:00', 0),
(387, 'Hilda', 'Titi Copacalle', '7315157', 'hildacopacalle@hotmail.com', 'Oruro', 0, '2017-08-25 14:53:14', 'participante', '0000-00-00 00:00:00', 0),
(388, 'Eva Maria', 'Gutierrez Choque', '12785185', 'evamariagutierrezchoque@gmail.com', 'Yacuiba', 0, '2017-08-25 14:54:01', 'participante', '0000-00-00 00:00:00', 0),
(389, 'Maria del Carmen', 'Palomo Flores', '7135813', 'marypalomo18@gmail.com', 'Yacuibq', 0, '2017-08-25 14:54:52', 'participante', '0000-00-00 00:00:00', 0),
(390, 'dadeck cadir', 'camacho', '5790180', 'genesiscadir@gmail.com', 'Yacuiba', 0, '2017-08-25 14:55:46', 'participante', '0000-00-00 00:00:00', 0),
(391, 'Cristian Boris', 'Cardozo Zurita', '10624713', 'Cristiancardozo423@gmail.com', 'Yacuiba', 0, '2017-08-25 14:57:26', 'participante', '0000-00-00 00:00:00', 0),
(392, 'Gustavo Alejandro', 'Mamani Villena', '7222711', 'alevil.1573@gmail.com', 'Tarija', 0, '2017-08-25 15:10:43', 'participante', '0000-00-00 00:00:00', 0),
(393, 'Isaias Jonatan', 'Cruz Castillo', '10660203', 'isaiastja@gmail.com', 'Yacuiba', 0, '2017-08-25 17:14:49', 'participante', '0000-00-00 00:00:00', 0),
(394, 'Diego', 'Garcia Pablo', '5790853', 'diego.g.pablo@gmail.com', 'Yacuiba', 0, '2017-08-25 17:38:03', 'participante', '0000-00-00 00:00:00', 0),
(395, 'Madelem nayra', 'Mamani nina', '7418537', 'prinsmadecareyou@gmail.com', 'El Alto', 0, '2017-08-25 18:58:54', 'participante', '0000-00-00 00:00:00', 0),
(396, 'JULIO CESAR', 'ROJAS AGUILAR', '10639445', 'JULIOCESARROJASAGUILAR22@GMAIL.COM', 'YACUIBA', 0, '2017-08-25 19:08:05', 'participante', '0000-00-00 00:00:00', 0),
(397, 'Cristhian Joel', 'Ayzama', '8541248', 'cristhianayzama5@Gmail.com', 'Sucre', 0, '2017-08-25 19:09:09', 'participante', '0000-00-00 00:00:00', 0),
(398, 'Yris Yoselin', 'Vargas Ayala', '8188983', 'yrijovay@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-25 19:26:00', 'participante', '0000-00-00 00:00:00', 0),
(399, 'Cristhian Luis', 'Nina Laura', '7164701', 'goootyx@gmail.com', 'Yacuiba', 0, '2017-08-25 20:28:05', 'participante', '0000-00-00 00:00:00', 0),
(400, 'Jorge Luis', 'Guarachi choque', '5946959', 'miranatemplar@gmail.com', 'La Paz', 0, '2017-08-25 20:37:21', 'participante', '0000-00-00 00:00:00', 0),
(401, 'Royer', 'Zurita zeballos', '9680097 sc', 'royer.zurita.zeballos@gmail', 'Santa Cruz de la Sierra', 0, '2017-08-25 20:38:17', 'participante', '0000-00-00 00:00:00', 0),
(402, 'Jorge Walter', 'Yankovic salmón', '7033722', 'jorge0112@hotmail.com', 'La Paz', 0, '2017-08-25 23:26:17', 'participante', '0000-00-00 00:00:00', 0),
(403, 'Lady candelaria', 'Choque Torrez', '9083874', 'lady-leyla03@hotmail.com', 'La Paz', 0, '2017-08-26 00:11:50', 'participante', '0000-00-00 00:00:00', 0),
(404, 'Guery', 'Castaño Apaza', '6843398', 'guerycastano@gmail.com', 'La Paz', 0, '2017-08-26 00:25:07', 'participante', '0000-00-00 00:00:00', 0),
(405, 'Ximena Stefania', 'Cordero Maydana', '10913746', 'cor.xime@gmail.com', 'La Paz', 0, '2017-08-26 00:49:40', 'participante', '0000-00-00 00:00:00', 0),
(406, 'Blanca Estefany', 'Salinas Flores', '10031207', 'besfestefany@gmail.com', 'La Paz', 0, '2017-08-26 01:59:33', 'participante', '0000-00-00 00:00:00', 0),
(407, 'Pedro Abraham', 'Arteaga Arteaga', '8352260', 'pedregales5@gmail.com', 'La paz', 0, '2017-08-26 05:57:50', 'participante', '0000-00-00 00:00:00', 0),
(408, 'Jesus Alberto', 'Arias Aguilar', '10001145', 'ariasantana21@gmail.com', 'La paz', 0, '2017-08-26 07:49:38', 'participante', '0000-00-00 00:00:00', 0),
(409, 'Ana Marlene', 'Ticona Flores', '3588198', 'marlenetf@gmail.com', 'Cochabamab', 0, '2017-08-26 16:20:26', 'participante', '0000-00-00 00:00:00', 0),
(410, 'Héctor gustavo', 'Fuentes lobo', '9680941', 'taiito09485@gmail.com', 'Oruro', 0, '2017-08-26 21:39:08', 'participante', '0000-00-00 00:00:00', 0),
(411, 'Andrea', 'Cornejo Moscoso', '10388390', 'andreacornejomoscoso@gmail.com', 'Sucre', 0, '2017-08-26 22:58:37', 'participante', '0000-00-00 00:00:00', 0),
(412, 'Andrea Luisa', 'Silvestre Lobo', '7287697`', 'andy.sil.lob@hotmail.com', 'Oruro', 0, '2017-08-27 00:39:57', 'participante', '0000-00-00 00:00:00', 0),
(413, 'Rusbelth', 'Mamani Tola', '9872324 LP', 'rusbelm37@gmail.com', 'La Paz', 0, '2017-08-27 00:45:18', 'participante', '0000-00-00 00:00:00', 0),
(414, 'Maria Selena', 'Sandoval Barba', '9842034', 'sele-bonita@hotmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-27 01:53:53', 'participante', '0000-00-00 00:00:00', 0),
(415, 'Jose Luis', 'Vaca Fernandez', '5362575', 'vakajose@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-27 02:29:15', 'participante', '0000-00-00 00:00:00', 0),
(416, 'Manuel Joaquín', 'Saavedra Severiche', '7713289', 'saavedramanuel100@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-27 02:50:19', 'participante', '0000-00-00 00:00:00', 0),
(417, 'Jorge Luis', 'Barrientos Cruz', '8536451', 'jorgeluisbarrientoscruz@gmail.com', 'Tarija', 0, '2017-08-27 14:56:24', 'participante', '0000-00-00 00:00:00', 0),
(418, 'YESSICA', 'MAMANI BAYO', '10624916', 'yes276ym@gmail.com', 'Yacuiba', 0, '2017-08-27 17:04:21', 'participante', '0000-00-00 00:00:00', 0),
(419, 'Carmen rosa', 'Marca paco', '10530228', 'marcapacocarmenrosa@gmail.com', 'Potosí', 0, '2017-08-27 18:12:07', 'participante', '0000-00-00 00:00:00', 0),
(420, 'Chh', 'Ggv', 'Fgv', 'cgg@hjj', 'Hhh', 0, '2017-08-27 19:48:00', 'participante', '0000-00-00 00:00:00', 0),
(421, 'Jose Luis', 'Mercado Alarcon', '8174701', 'joseluismercadoalarcon@gmail.com', 'Tarija', 0, '2017-08-27 20:11:28', 'participante', '0000-00-00 00:00:00', 0),
(422, 'Alexander Willam', 'Vera Paco', '7231881', 'averapaco@gmail.com', 'Tarija', 0, '2017-08-27 20:21:02', 'participante', '0000-00-00 00:00:00', 0),
(423, 'Natalia Elva', 'Calle Terrazas', '10650825', 'natalia.callet@gmail.com', 'Tarija', 0, '2017-08-27 20:23:51', 'participante', '0000-00-00 00:00:00', 0),
(424, 'Joan Sebastian', 'Choque Guevara', '10650461', 'joansebastianchoque@gmail.com', 'Tarija', 0, '2017-08-27 20:53:10', 'participante', '0000-00-00 00:00:00', 0),
(425, 'Joel tevis', 'Gómez andrade', '7846359 S.C.', 'jhoelgmz123@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-27 21:21:20', 'participante', '0000-00-00 00:00:00', 0),
(426, 'Víctor Hugo', 'Tirado Peñaranda', '8636492', 'victorpr7330@gmail.com', 'Potosí', 0, '2017-08-27 21:21:54', 'participante', '0000-00-00 00:00:00', 0),
(427, 'Eddy Rodrigo', 'Ramos', '8324186 Lp', 'eddyinf605@gmail.com', 'La Paz', 0, '2017-08-27 21:56:22', 'participante', '0000-00-00 00:00:00', 0),
(428, 'Julio César', 'Zarcillo Justiniano', '9710242', 'juliocesar.zj@outlook.com', 'Santa cruz', 0, '2017-08-27 23:45:50', 'participante', '0000-00-00 00:00:00', 0),
(429, 'Luis Alberto', 'Segovia', '10690483', 'asego00@gmail.com', 'Tarija', 0, '2017-08-28 00:21:25', 'participante', '0000-00-00 00:00:00', 0),
(430, 'Diego Edil', 'Ramos Colque', '8739968', 'edil_son676@hotmail.com', 'La Paz', 0, '2017-08-28 01:45:26', 'participante', '0000-00-00 00:00:00', 0),
(431, 'Fabricio', 'Veneros Vasquez', '9128493', 'fabro.veneros@gmail.com', 'La Paz', 0, '2017-08-28 02:40:56', 'participante', '0000-00-00 00:00:00', 0),
(432, 'Mayra Rosario', 'Pallarico Quisbert', '8345831', 'rosariosungminnie@gmail.com', 'La Paz', 0, '2017-08-28 03:23:07', 'participante', '0000-00-00 00:00:00', 0),
(433, 'Yessica', 'Rodriguez Castro', '???10524695', 'yzik0911@gmail.com', 'Tarija', 0, '2017-08-28 10:21:43', 'participante', '0000-00-00 00:00:00', 0),
(434, 'Luis Gabriel', 'Torrez Rojas', '9899313', 'moretzluis@gmail.com', 'La Paz', 0, '2017-08-28 14:41:49', 'participante', '0000-00-00 00:00:00', 0),
(435, 'Raul Alberto', 'Chura Pajarito', '10737664', 'alberto.123.ac25@gmail.com', 'Tarija', 0, '2017-08-28 14:45:40', 'participante', '0000-00-00 00:00:00', 0),
(436, 'Daniel', 'Barreda Quispe', '8333906', 'danielbarreda34@gmail.com', 'La Paz', 0, '2017-08-28 15:02:48', 'participante', '0000-00-00 00:00:00', 0),
(437, 'Hugo', 'Arenas Vaca', '7155798', 'hugoarenas92@gmail.com', 'Tarija', 0, '2017-08-28 15:43:38', 'participante', '0000-00-00 00:00:00', 0),
(438, 'william', 'Luque rojas', '9218868', 'jdkwlrlw@gmail.com', 'La Paz', 0, '2017-08-28 17:48:29', 'participante', '0000-00-00 00:00:00', 0),
(439, 'Luis Diego', 'Borja Potigo', '11379205', 'luisdiegoborja@hotmail.com', 'Sucre', 0, '2017-08-28 18:41:53', 'participante', '0000-00-00 00:00:00', 0),
(440, 'Alvaro Luis', 'Zapata Moscoso', '10331470', 'alvarito_5_5@hotmail.com', 'Sucre', 0, '2017-08-28 18:46:04', 'participante', '0000-00-00 00:00:00', 0),
(441, 'Pedro Luis', 'Acho Zarate', '8178854', 'achozarate@gmail.com', 'Sucre', 0, '2017-08-28 18:51:22', 'participante', '0000-00-00 00:00:00', 0),
(442, 'Wilzor Tito', 'Huanca Colque', '7554515', 'wilzorjho@gmail.com', 'Sucre', 0, '2017-08-28 18:53:21', 'participante', '0000-00-00 00:00:00', 0),
(443, 'Thomas', 'Carmona Calvimontes', '7538295', 'mezoreth@gmail.com', 'Sucre', 0, '2017-08-28 18:56:05', 'participante', '0000-00-00 00:00:00', 0),
(444, 'Fabiola Isela', 'Callizaya Huanca', '8286304', 'iscah_fabi27@yahoo.es', 'La Paz', 0, '2017-08-28 20:33:42', 'participante', '0000-00-00 00:00:00', 0),
(445, 'Waldo', 'Villanueva Gonzales', '10307717', 'geralnede@gmail.com', 'Sucre', 0, '2017-08-28 20:36:29', 'participante', '0000-00-00 00:00:00', 0),
(446, 'Luis Alfonso', 'Ramírez García', '12929543', 'strikeronetwo5@gmail.com', 'Sucre', 0, '2017-08-28 20:52:45', 'participante', '0000-00-00 00:00:00', 0),
(447, 'jhonatan roly', 'galvez lazo', '10953536', 'jhonatangalvez4@gmail.com', 'La Paz', 0, '2017-08-28 21:32:01', 'participante', '0000-00-00 00:00:00', 0),
(448, 'Brian Miguel', 'Chura Siñani', '8484564', 'sygfrid1@gmail.com', 'La Paz', 0, '2017-08-28 21:59:13', 'participante', '0000-00-00 00:00:00', 0),
(449, 'Gustavo', 'Mendoza Paredes', '6172349', 'gustavo.mendoza.paredes@gmail.com', 'La Paz', 0, '2017-08-28 22:16:19', 'participante', '0000-00-00 00:00:00', 0),
(450, 'Noemí', 'Mamani Álvarez', '5799459 Tj', 'nomy.1752@gmail.com', 'La Paz', 0, '2017-08-28 22:18:25', 'participante', '0000-00-00 00:00:00', 0),
(451, 'Dimelza', 'Quispe Leon', '8422174', 'dimelzzzzza19@gmail.com', 'La Paz', 0, '2017-08-28 22:24:42', 'participante', '0000-00-00 00:00:00', 0),
(452, 'José Luis', 'Vedia Maturano', '12611478', 'josevedia2405@gmail.com', 'Sucre', 0, '2017-08-28 22:58:41', 'participante', '0000-00-00 00:00:00', 0),
(453, 'Marcelo Alex', 'Fernández Salazar', '8329574', 'light_34_65@hotmail.com', 'La Paz', 0, '2017-08-28 23:30:15', 'participante', '0000-00-00 00:00:00', 0),
(454, 'Yenny Giovana', 'Ticona Cabrera', '7212180', 'yennytc.143@gmail.com', 'Tarija', 0, '2017-08-28 23:43:26', 'participante', '0000-00-00 00:00:00', 0),
(455, 'juan', 'perez', '65685699999', 'cechuscsc4@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-28 23:50:07', 'participante', '0000-00-00 00:00:00', 0),
(456, 'Franklin', 'Correa paco', '9048275', 'franklincorrea373@gmail.com', 'Sucre', 0, '2017-08-29 00:08:44', 'participante', '0000-00-00 00:00:00', 0),
(457, 'Milton Andres', 'Rodriguez', '9713640', 'tnet.1000ton@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-29 00:44:26', 'participante', '0000-00-00 00:00:00', 0),
(458, 'LIZBETH', 'TORRICO CORDOVA', '4485222', 'bethliz_15@hotmail.com', 'sucre', 0, '2017-08-29 01:27:28', 'participante', '0000-00-00 00:00:00', 0),
(459, 'sergio orlando', 'mauricio macuri', '9103896', 'Maur0-hellfish-@hotmail.com', 'La Paz', 0, '2017-08-29 02:26:21', 'participante', '0000-00-00 00:00:00', 0);
INSERT INTO `user` (`id`, `name`, `last_name`, `ci`, `email`, `city`, `paid`, `registration_date`, `cargo`, `inscription_date`, `id_admin`) VALUES
(460, 'Josué Marco', 'Lemus Miranda', '8467805 Lp', 'josueunueve@gmail.com', 'La Paz', 0, '2017-08-29 03:37:45', 'participante', '0000-00-00 00:00:00', 0),
(461, 'Erik Daniel', 'Castro Daza', '5686968', 'polmenwer32@gmail.com', 'Sucre', 0, '2017-08-29 11:54:13', 'participante', '0000-00-00 00:00:00', 0),
(462, 'Andres Julio', 'Murillo Mamani', '8340433', 'andrus126@gmail.com', 'La Paz', 0, '2017-08-29 12:07:33', 'participante', '0000-00-00 00:00:00', 0),
(463, 'Gustavo', 'Aguilar Torres', '13616192', 'stdiogustavoaguilartorres1@gmail.com', 'Sucre', 0, '2017-08-29 12:55:35', 'participante', '0000-00-00 00:00:00', 0),
(464, 'Gunnar Cristhian', 'Cardozo Cardozo', '7512628', 'gunnarcardozo@gmail.com', 'Sucre', 0, '2017-08-29 13:28:22', 'participante', '0000-00-00 00:00:00', 0),
(465, 'Fabrizio Daniel', 'Lopez Mejia', '7484132', 'blockdaniel123456789@gmail.com', 'Sucre', 0, '2017-08-29 14:54:26', 'participante', '0000-00-00 00:00:00', 0),
(466, 'Jose Armando', 'Huallpa Salazar', '13956801', 'jahs546@gmail.com', 'Sucre', 0, '2017-08-29 14:57:19', 'participante', '0000-00-00 00:00:00', 0),
(467, 'Dayber', 'Lezano castro', '13251535', 'deyberking@gmail.com', 'Sucre', 0, '2017-08-29 15:00:20', 'participante', '0000-00-00 00:00:00', 0),
(468, 'Javier Milton', 'Copa Condori', '10537061', 'jcopa422@gmail.com', 'sucre', 0, '2017-08-29 15:17:10', 'participante', '0000-00-00 00:00:00', 0),
(469, 'Pamela', 'Leon Mamani', '7285237', 'pam.yo@hotmail.com', 'Oruro', 0, '2017-08-29 15:31:04', 'participante', '0000-00-00 00:00:00', 0),
(470, 'Javier Andres', 'Tavera Sandoval', '10410333 CH.', 'jats.sr2016swag@gmail.com', 'Sucre', 0, '2017-08-29 15:48:40', 'participante', '0000-00-00 00:00:00', 0),
(471, 'Joel Alejandro', 'Ríos Vargas', '7520317', 'joelrios077@gmail.com', 'Sucre', 0, '2017-08-29 15:56:26', 'participante', '0000-00-00 00:00:00', 0),
(472, 'Ruddy', 'Condori Sandoval', '9890494', 'frostmour2013@gmail.com', 'La Paz', 0, '2017-08-29 16:31:36', 'participante', '0000-00-00 00:00:00', 0),
(473, 'benichu', 'pamela', '5632414', 'davida@mailna.co', 'sucre', 0, '2017-08-29 17:05:08', 'participante', '0000-00-00 00:00:00', 0),
(474, 'pijaso', 'pijaqsman', '10356941', 'qwety@mailna.co', 'sucre', 0, '2017-08-29 17:09:57', 'participante', '0000-00-00 00:00:00', 0),
(475, 'Daniel', 'Quispe Ricalde', '6693420', 'daniel.qricalde@gmail.com', 'Sucre', 0, '2017-08-29 18:47:54', 'participante', '0000-00-00 00:00:00', 0),
(476, 'Juan Ignacio', 'Rasguido Higueras', '10333537', 'Irasguidohigueras@gmail.com', 'Sucre', 0, '2017-08-29 19:10:19', 'participante', '0000-00-00 00:00:00', 0),
(477, 'Vladimir', 'Torrez Alba', '10355798', 'vladimir.torrez14@gmail', 'Sucre', 0, '2017-08-29 19:13:49', 'participante', '0000-00-00 00:00:00', 0),
(478, 'Ruben Dario', 'Torres Mendez', '7504124 Ch.', 'rd.tomz.777@gmail.com', 'Sucre', 0, '2017-08-29 19:18:37', 'participante', '0000-00-00 00:00:00', 0),
(479, 'Cristian Orlando', 'Flores Rodriguez', '8594633', 'cristianfrodriguezz@gmail.com', 'Sucre', 0, '2017-08-29 20:39:34', 'participante', '0000-00-00 00:00:00', 0),
(480, 'Guillermo', 'Tola monataño', '8508696', 'guichi_1000@hotmail.com', 'Potosí', 0, '2017-08-29 20:50:11', 'participante', '0000-00-00 00:00:00', 0),
(481, 'Omar Gerardo', 'Flores Diaz', '12764917', 'dgerardo664@gmail.com', 'La Paz', 0, '2017-08-29 21:24:04', 'participante', '0000-00-00 00:00:00', 0),
(482, 'Juan Pablo', 'Estrada cuno', '8617852', 'bambino_3008@hotmail.com', 'Potosi', 0, '2017-08-29 21:25:56', 'participante', '0000-00-00 00:00:00', 0),
(483, 'Jose Vladimir', 'Marquéz', '4006608', 'jm9641980@gmail.com', 'Potosi', 0, '2017-08-29 21:28:13', 'participante', '0000-00-00 00:00:00', 0),
(484, 'Jhovanna', 'Quispe arriaga', '8505358-1M', 'gatiposa@gmail.com', 'Potosi', 0, '2017-08-29 21:34:14', 'participante', '0000-00-00 00:00:00', 0),
(485, 'Reina', 'Huanaco Choque', '10536222', 'reina_guay18@hotmail.com', 'Potosi', 0, '2017-08-29 21:34:19', 'participante', '0000-00-00 00:00:00', 0),
(486, 'Mario Edson', 'Pimentel Romero', '10340797', 'marioedsopimentel757887@gmail.com', 'Sucre', 0, '2017-08-29 23:10:08', 'participante', '0000-00-00 00:00:00', 0),
(487, 'Haen Mauricio', 'Mita Gumiel', '10349698', 'haen-@live.com', 'Sucre', 0, '2017-08-29 23:26:40', 'participante', '0000-00-00 00:00:00', 0),
(488, 'Wilver', 'Gonzales Condo', '8574258', 'wilver18058917@gmail.com', 'Potosi', 0, '2017-08-29 23:32:25', 'participante', '0000-00-00 00:00:00', 0),
(489, 'Laura', 'Pérez Prudencio', '12751037', 'lpp180299@gmail.com', 'Sucre', 0, '2017-08-30 00:56:54', 'participante', '0000-00-00 00:00:00', 0),
(490, 'Iveth yumara', 'Mamani Gutierrez', '5490289', 'ivethyumara.mg@gmail.com', 'Sucre', 0, '2017-08-30 00:59:43', 'participante', '0000-00-00 00:00:00', 0),
(491, 'Jhoseline Tatiana', 'Romero León', '8532143', 'tatis.5soslove@gmail.com', 'Sucre', 0, '2017-08-30 01:14:13', 'participante', '0000-00-00 00:00:00', 0),
(492, 'Richard', 'Mayta', '9245056', 'maytat25@hotmail.com', 'La Paz', 0, '2017-08-30 01:43:54', 'participante', '0000-00-00 00:00:00', 0),
(493, 'José Franco', 'Quispe Averanga', '4875411', 'jfqa32@gmail.com', 'La Paz', 0, '2017-08-30 01:54:14', 'participante', '0000-00-00 00:00:00', 0),
(494, 'Jorge Luis', 'Nina Flores', '7567271', 'jorgenina3942@gmail.com', 'Sucre', 0, '2017-08-30 02:59:16', 'participante', '0000-00-00 00:00:00', 0),
(495, 'Juan Eloy', 'Espozo Espinoza', '3988925 PT.', 'eloy@ucb.edu.bo', 'La Paz', 0, '2017-08-30 04:56:47', 'participante', '0000-00-00 00:00:00', 0),
(501, 'test', 'test', 'test', 'test@gmail.com', 'test', 0, '2017-08-30 09:45:18', 'participante', '0000-00-00 00:00:00', 0),
(502, 'test1', 'test1', 'test1', 'test1@gmail.com', 'test1@gmail.com', 0, '2017-08-30 09:46:07', 'participante', '0000-00-00 00:00:00', 0),
(503, 'test2', 'test2', 'test2', 'test2@gamil.com', 'test2', 0, '2017-08-30 09:48:06', 'participante', '0000-00-00 00:00:00', 0),
(504, 'test3', 'test3', 'test3', 'test3@gmail.com', 'test3', 0, '2017-08-30 09:50:11', 'participante', '0000-00-00 00:00:00', 0),
(505, 'test4', 'test4', 'test4', 'test4@gmail.com', 'test4', 0, '2017-08-30 09:51:01', 'participante', '0000-00-00 00:00:00', 0),
(506, 'test5', 'test5', 'test5', 'test5@gmail.com', 'test5', 0, '2017-08-30 09:52:13', 'participante', '0000-00-00 00:00:00', 0),
(507, 'test6', 'test6', 'test6', 'test6@gmail.com', 'test6', 0, '2017-08-30 09:53:04', 'participante', '0000-00-00 00:00:00', 0),
(508, 'test7', 'test7', 'test7', 'test7@gmail.com', 'test7', 0, '2017-08-30 09:55:35', 'participante', '0000-00-00 00:00:00', 0),
(509, 'HIDIBERTO ABRAHAN', 'SECKO CRUZ', '8520355', 'eliot.888pirata@gmail.com', 'Potosí', 0, '2017-08-30 11:18:15', 'participante', '0000-00-00 00:00:00', 0),
(510, 'Katherine Jennifer', 'Coro Callaguara', '12803095', 'kathynogarami24@gmail.com', 'Sucre', 0, '2017-08-30 11:32:04', 'participante', '0000-00-00 00:00:00', 0),
(511, 'Amalia Ximena', 'Mamani Arriaga', '14106486', 'amelia18mamani@gmail.com', 'Sucre', 0, '2017-08-30 12:35:23', 'participante', '0000-00-00 00:00:00', 0),
(512, 'Osmar Andres', 'Azurduy Durán', '8568371', 'osmarazurduy@gmail.com', 'Sucre', 0, '2017-08-30 12:51:52', 'participante', '0000-00-00 00:00:00', 0),
(513, 'Shirley maite', 'Cruz solamayo', '7465828', 'shirleycruz.bo@gmail.com', 'Sucre', 0, '2017-08-30 13:15:31', 'participante', '0000-00-00 00:00:00', 0),
(514, 'Eddy', 'Escalante', '7852166 SC', 'eddyeu59@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-30 13:22:32', 'participante', '0000-00-00 00:00:00', 0),
(515, 'Amanda', 'Buchizo Calderon', '7536815', 'opetita15@gmail.com', 'Sucre', 0, '2017-08-30 13:50:52', 'participante', '0000-00-00 00:00:00', 0),
(516, 'Nelson Fabian', 'Sanchez Gareca', '7221441', 'nelsonfabiansanchezgareca@gmail.com', 'Tarija', 0, '2017-08-30 13:51:14', 'participante', '0000-00-00 00:00:00', 0),
(517, 'Osvaldo', 'Garcia Rojas', '10411401', 'lobo972016@gmail.com', 'Sucre', 0, '2017-08-30 13:59:23', 'participante', '0000-00-00 00:00:00', 0),
(518, 'Felix', 'Vargas Vela', '10317524', 'felixvar91@gmail.com', 'Sucre', 0, '2017-08-30 14:08:40', 'participante', '0000-00-00 00:00:00', 0),
(519, '56gfhfg', 'hdfh56', '1234abc', 'algo@gmail.com', 'Sucre', 0, '2017-08-30 14:14:39', 'participante', '0000-00-00 00:00:00', 0),
(520, 'Eloy', 'Leandro Villanueva', '12527201', 'eleanvilla01@gmail.com', 'Potosí', 0, '2017-08-30 15:15:05', 'participante', '0000-00-00 00:00:00', 0),
(521, 'ROLANDO PATRICIO', 'LAGUNA', '4201314', 'rolandolq17@gmail.com', 'La Paz', 0, '2017-08-30 15:37:28', 'participante', '0000-00-00 00:00:00', 0),
(522, 'Joel Luis', 'Chambilla renjel', '6827237', 'joel.luis.cr@gmail.com', 'La Paz', 0, '2017-08-30 16:22:11', 'participante', '0000-00-00 00:00:00', 0),
(523, 'Agmed', 'Fernández Garcia', '7515846', 'agmedfernandez@gmail.com', 'Sucre', 0, '2017-08-30 16:40:14', 'participante', '0000-00-00 00:00:00', 0),
(524, 'Alison Paola', 'Jancko Fuentes', '8507413', 'ali.apjf@gmail.com', 'Sucre', 0, '2017-08-30 16:40:53', 'participante', '0000-00-00 00:00:00', 0),
(525, 'Nehemias Francisco', 'Lenis Rodríguez', '8549223', 'franz.lr.xd@gmail.com', 'Potosí', 0, '2017-08-30 18:12:25', 'participante', '0000-00-00 00:00:00', 0),
(526, 'Luis Fernando', 'Duran Rosas', '3658212', 'luis3658duran@gmail.com', 'Sucre', 0, '2017-08-30 18:28:35', 'participante', '0000-00-00 00:00:00', 0),
(527, 'Franz Franco', 'Mamani Mamani', '10544428', 'mamanir117@gmail.com', 'Sucre', 0, '2017-08-30 19:26:23', 'participante', '0000-00-00 00:00:00', 0),
(528, 'ERWIN VLADIMIR', 'CHIJO HUARANCA', '8615709', 'g2sis313vlady@gmail.com', 'Potosí', 0, '2017-08-30 19:35:40', 'participante', '0000-00-00 00:00:00', 0),
(529, 'Alvaro Joaquin', 'Duran Paredes', '5686054', 'nanoo.duran@gmail.com', 'Sucre', 0, '2017-08-30 19:44:51', 'participante', '0000-00-00 00:00:00', 0),
(530, 'Harold Adolfo', 'Quezada', '5638049', 'haroldquezada82@gmail.com', 'Sucre', 0, '2017-08-30 19:47:38', 'participante', '0000-00-00 00:00:00', 0),
(531, 'Sergio', 'Mendoza Benito', '10307587', 'pxndxkirx@gmail.com', 'Sucre', 0, '2017-08-30 19:49:03', 'participante', '0000-00-00 00:00:00', 0),
(532, 'Vivian Amparo', 'Herrera Aduviri', '4915678LP', 'vivian.herrera.1982@gmail.com', 'Sucre', 0, '2017-08-30 19:53:15', 'participante', '0000-00-00 00:00:00', 0),
(533, 'Faustino', 'Ochoa Gonzales', '12705980', 'ochoafaustino15@gmail.com', 'Sucre', 0, '2017-08-30 20:02:26', 'participante', '0000-00-00 00:00:00', 0),
(534, 'Juan Carlos', 'Amador Yucra', '10381896', 'juancarlosamadoryucra@gmail.com', 'Sucre', 0, '2017-08-30 20:09:40', 'participante', '0000-00-00 00:00:00', 0),
(535, 'Miguel Arnold', 'Cruz Calcina', '12653837', 'cruzcalcinamiguelarnold@gmail.com', 'Sucre', 0, '2017-08-30 20:18:20', 'participante', '0000-00-00 00:00:00', 0),
(536, 'Roman', 'Colque Quispe', '6667229', 'romancolque@gmail.com', 'Sucre', 0, '2017-08-30 20:23:51', 'participante', '0000-00-00 00:00:00', 0),
(537, 'RUBEN', 'PACO HUACOTO', '7528158', 'rpacow@gmail.com', 'Sucre', 0, '2017-08-30 20:27:00', 'participante', '0000-00-00 00:00:00', 0),
(538, 'P1', 'P1', 'P1', 'p1@gmail.com', 'P1', 0, '2017-08-30 20:43:32', 'participante', '0000-00-00 00:00:00', 0),
(539, 'Franklin Riabani', 'Mercado Flores', '4536427', 'franklin.riabani@gmail.com', 'Cochabamba', 0, '2017-08-30 20:51:58', 'participante', '0000-00-00 00:00:00', 0),
(540, 'P2', 'P2', 'P2', 'p2@gmail.com', 'P2', 0, '2017-08-30 21:09:07', 'participante', '0000-00-00 00:00:00', 0),
(541, 'Miguel Angel', 'Aceituno Avalos', '10402828', 'micky_picis12@hotmail.com', 'Sucre', 0, '2017-08-30 21:11:34', 'participante', '0000-00-00 00:00:00', 0),
(542, 'Ronald', 'Garcia Arancibia', '7540752', 'ronaldgarcia303@gmail.com', 'Sucre', 0, '2017-08-30 21:21:21', 'participante', '0000-00-00 00:00:00', 0),
(543, 'Herald', 'Choque Vargas', '6680287', 'Heraldcnp@gmail.com', 'Potosí', 0, '2017-08-30 21:40:29', 'participante', '0000-00-00 00:00:00', 0),
(544, 'Cristhian Walter', 'Calsina Choque', '12436391', 'cristhianwaltercalsinachoque@gmail.com', 'Sucre', 0, '2017-08-30 21:43:46', 'participante', '0000-00-00 00:00:00', 0),
(545, 'Jhisela', 'Llanque Mollo', '10507456', 'lajhis.1692@gmail.com', 'Sucre', 0, '2017-08-30 22:00:41', 'participante', '0000-00-00 00:00:00', 0),
(546, 'Karlita', 'Sevilla', '5402349', 'Ksevilla.24.l@gmail.com', 'Sucre', 0, '2017-08-30 22:02:49', 'participante', '0000-00-00 00:00:00', 0),
(547, 'Willans Misael', 'Romero Condori', '10524845', 'willansmisaelromerocondori@gmail.com', 'Sucre', 0, '2017-08-30 22:03:34', 'participante', '0000-00-00 00:00:00', 0),
(548, 'Juan Sergio', 'Villafan Canizares', '7537657', 'villafan815@gmail.com', 'Sucre', 0, '2017-08-30 22:05:22', 'participante', '0000-00-00 00:00:00', 0),
(549, 'Pollo', 'Pollo', 'Pollo', 'pollo@gmail.com', 'Pollo', 0, '2017-08-30 22:07:49', 'participante', '0000-00-00 00:00:00', 0),
(550, 'Mayra elizabeth', 'chumacero vargas', '12376870', 'mayrita-27amig@hotmail.com', 'potosi', 0, '2017-08-30 22:15:32', 'participante', '0000-00-00 00:00:00', 0),
(551, 'Jose Amilcar', 'Arancibia Soto', '8506729', 'amilcar.007@hotmail.com', 'Sucre', 0, '2017-08-30 22:20:15', 'participante', '0000-00-00 00:00:00', 0),
(552, 'haeintz', 'mariscal borja', '6707091', 'hantz_angel14@hotmail.com', 'potosi', 0, '2017-08-30 22:20:32', 'participante', '0000-00-00 00:00:00', 0),
(553, 'Maribel', 'Vedia Perka', '10338181', 'maribel.vedia.ggg0064@gmail.com', 'Sucre', 0, '2017-08-30 22:27:53', 'participante', '0000-00-00 00:00:00', 0),
(554, 'julio alberto', 'flores miranda', '5500750', 'julioalbertofloresmiranda28@gmail.com', 'potosi', 0, '2017-08-30 22:53:48', 'participante', '0000-00-00 00:00:00', 0),
(555, 'Ivar Rolando', 'Vargas Flores', '4884820', 'ivardo2013@gmail.com', 'La Paz', 0, '2017-08-30 22:54:20', 'participante', '0000-00-00 00:00:00', 0),
(556, 'Jose Luis', 'Rodriguez Ramos', '5076463', 'jazlu574@gmail.com', 'Potosí', 0, '2017-08-30 23:01:03', 'participante', '0000-00-00 00:00:00', 0),
(557, 'Edith Maricel', 'Avendaño Correa', '7527633', 'emac109508@gmail.com', 'Sucre', 0, '2017-08-30 23:02:00', 'participante', '0000-00-00 00:00:00', 0),
(558, 'Ruben German', 'Mamani Mendez', '8523640', 'ruben_braun123@hotmail.com', 'Potosí', 0, '2017-08-30 23:02:21', 'participante', '0000-00-00 00:00:00', 0),
(559, 'alfredo', 'solis quiroga', '7929475', 'shanon.4ever@gmail.com', 'Cochabamba', 0, '2017-08-30 23:02:45', 'participante', '0000-00-00 00:00:00', 0),
(560, 'Nigel', 'Davila', '9428709', 'shanakawai.index@gmail.com', 'Cochabamba', 0, '2017-08-30 23:03:04', 'participante', '0000-00-00 00:00:00', 0),
(561, 'Israel', 'Arispe Torrico', '9393848', 'itachi_atsuki-shippuden@hotmail.com', 'Cochabamba', 0, '2017-08-30 23:04:16', 'participante', '0000-00-00 00:00:00', 0),
(562, 'Paolo Marco', 'Villarrubia Martinez', '6716402', 'paolexxx93@gmail.com', 'Sucre', 0, '2017-08-30 23:08:41', 'participante', '0000-00-00 00:00:00', 0),
(563, 'roberto carlos', 'gomez callapino', '10520891', 'robert.gomez.1709@gmail.com', 'potosi', 0, '2017-08-30 23:25:41', 'participante', '0000-00-00 00:00:00', 0),
(564, 'Ector Grover', 'Aguilar Martinez', '10509714', 'grovelar.1994@gmail.com', 'Potosí', 0, '2017-08-30 23:47:19', 'participante', '0000-00-00 00:00:00', 0),
(565, 'Erick Roberto', 'Colque Huayllas', '6696973', 'erick_221_@outlook.com', 'Potosí', 0, '2017-08-31 00:39:00', 'participante', '0000-00-00 00:00:00', 0),
(566, 'GIMENA ROSALIA', 'CASTRO CABRERA', '10539800', 'zombie1gime@gmail.com', 'Potosí', 0, '2017-08-31 00:51:42', 'participante', '0000-00-00 00:00:00', 0),
(567, 'gustavo daniel', 'mamani martinez', '8417714', 'gustavodanielmamanimartinez81@gmail.com', 'La Paz', 0, '2017-08-31 00:56:54', 'participante', '0000-00-00 00:00:00', 0),
(568, 'p3', 'p3', 'p3', 'p3@gmail.com', 'Sucre', 0, '2017-08-31 02:56:16', 'participante', '0000-00-00 00:00:00', 0),
(569, 'Jose Gonzalo', 'Olivarez Bolivar', '8347981', 'olivarez.bolivar@gmail.com', 'La Paz', 0, '2017-08-31 03:04:08', 'participante', '0000-00-00 00:00:00', 0),
(570, 'emmmm', 'mwwwww', '3234567345', 'eeeee@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-31 04:54:17', 'participante', '0000-00-00 00:00:00', 0),
(571, 'jasson raul', 'salinas estrada', '12376469', 'jraul1234512@gmail.com', 'Potosí', 0, '2017-08-31 04:54:44', 'participante', '0000-00-00 00:00:00', 0),
(572, 'Gabriel', 'Casas bustillos', '14271444', 'gabrielito_14_98@yahoo.com', 'Santa Cruz de la u', 0, '2017-08-31 05:08:49', 'participante', '0000-00-00 00:00:00', 0),
(573, 'Juan Carlos', 'Mamani Laura', '6920900', 'yhon.1yhon@gmail.com', 'Cobija', 0, '2017-08-31 10:38:31', 'participante', '0000-00-00 00:00:00', 0),
(574, 'Joel Orlando', 'Mamani Mariño', '10335436', 'levitajoel@outlook.com', 'Sucre', 0, '2017-08-31 10:49:21', 'participante', '0000-00-00 00:00:00', 0),
(575, 'Brolin', 'Valverde Chambi', '12346989', 'brolinvc@gmail.com', 'Potosi', 0, '2017-08-31 11:55:25', 'participante', '0000-00-00 00:00:00', 0),
(576, 'María Elena', 'Antezana Barnack', '4630147', 'maria.elena.antezana.b@gmail.com', 'Sucre', 0, '2017-08-31 12:33:29', 'participante', '0000-00-00 00:00:00', 0),
(577, 'Jorge', 'Gallego Almanza', '843829', 'ariel@hotmail.com', 'Llallagua', 0, '2017-08-31 12:40:25', 'participante', '0000-00-00 00:00:00', 0),
(578, 'silvia Eugenia', 'Villalba Yevara', '7557266', 'silvita7557@gmail.com', 'Sucre', 0, '2017-08-31 12:50:00', 'participante', '0000-00-00 00:00:00', 0),
(579, 'Xana   Valeria', 'Prudecio Lejsek', '9360019', 'florecitarokera78@gmail.com', 'Sucre', 0, '2017-08-31 13:22:46', 'participante', '0000-00-00 00:00:00', 0),
(580, 'Omar', 'Nuñez del Prado Flores', '12406154', 'gtsko@hotmail.com', 'Sucre', 0, '2017-08-31 13:53:50', 'participante', '0000-00-00 00:00:00', 0),
(581, 'Erik Rodrigo', 'Mamani Espinoza', '5108852', 'alcoholika1@gmail.com', 'Sucre', 0, '2017-08-31 14:04:06', 'participante', '0000-00-00 00:00:00', 0),
(582, 'Nataly lucero', 'Miranda copa', '5568087', 'sis331natalymirandacopa@gmail.com', 'Potosí', 0, '2017-08-31 14:33:36', 'participante', '0000-00-00 00:00:00', 0),
(583, 'Marco Antonio', 'Tuco Chambi', '9070368 L.P.', 'mtucochambi@gmail.com', 'La Paz', 0, '2017-08-31 14:51:41', 'participante', '0000-00-00 00:00:00', 0),
(584, 'Wilson', 'Macias Valencia', '7561166', 'wmv8400@gmail.com', 'wmv8400@gmail.com', 0, '2017-08-31 15:17:21', 'participante', '0000-00-00 00:00:00', 0),
(585, 'Talia', 'Beltran ruiz', '12557755', 'talia_lovekiss.1515@hotmail.com', 'Potosí', 0, '2017-08-31 15:20:14', 'participante', '0000-00-00 00:00:00', 0),
(586, 'Soledad', 'Coro mamanillo', '10461346', 'soledadcoro297@gmail.com', 'Potosí', 0, '2017-08-31 15:23:59', 'participante', '0000-00-00 00:00:00', 0),
(587, 'Alexander', 'Choque Polo', '7838712', 'alexanderchoquepolo@gmail.com', 'Sucre', 0, '2017-08-31 15:24:10', 'participante', '0000-00-00 00:00:00', 0),
(588, 'Fraya Jhemina', 'Chambi', '10345214', 'jhemi94@gmail.com', 'Sucre', 0, '2017-08-31 15:32:24', 'participante', '0000-00-00 00:00:00', 0),
(589, 'Franchesca Noelia', 'Vela Acha', '6639776', 'noelia.vela.acha1@gmail.com', 'Sucre', 0, '2017-08-31 16:09:27', 'participante', '0000-00-00 00:00:00', 0),
(590, 'Jose Luis', 'Menacho Mamani', '8595920', 'josemenacho22@gmail.com', 'Sucre', 0, '2017-08-31 16:35:37', 'participante', '0000-00-00 00:00:00', 0),
(591, 'Alicia', 'Choca Caihuara', '10389038', 'alich3@gmail.com', 'Sucre', 0, '2017-08-31 16:44:44', 'participante', '0000-00-00 00:00:00', 0),
(592, 'Edwin Kennedy', 'Martínez Alarcón', '10422627', 'greenjoekennedy@gmail.com', 'Sucre', 0, '2017-08-31 16:44:56', 'participante', '0000-00-00 00:00:00', 0),
(593, 'Melannie', 'Bellido Ortuño', '13185828', 'bellidoortunomelannie@gmail.com', 'Sucre', 0, '2017-08-31 16:45:35', 'participante', '0000-00-00 00:00:00', 0),
(594, 'Jose Ignacio', 'Chuve Olivares', '12854441', 'chuve.olivares.jose.ignacio@gmail.com', 'Sucre', 0, '2017-08-31 17:14:24', 'participante', '0000-00-00 00:00:00', 0),
(595, 'Marcos Gustavo Saavedra Díaz', 'Saavedra Díaz', '10332666', 'marcosgus96@hotmail.com', 'Sucre', 0, '2017-08-31 17:21:18', 'participante', '0000-00-00 00:00:00', 0),
(596, 'Jesús Manuel', 'Egue Monterino', '7187002', 'egue.monterino.jesus.manuel@gmail.com', 'Sucre', 0, '2017-08-31 17:26:44', 'participante', '0000-00-00 00:00:00', 0),
(597, 'Sofia Roxana', 'Espejo Copaja', '4936134 L.P.', 'sofy_es_1@hotmail.com', 'La Paz', 0, '2017-08-31 18:04:21', 'participante', '0000-00-00 00:00:00', 0),
(598, 'Marisabel', 'Flores kacka', '10576837', 'maryfloreskacka@gmail.com', 'Potosí', 0, '2017-08-31 18:27:24', 'participante', '0000-00-00 00:00:00', 0),
(599, 'Josue Ramiero', 'Meneses Caero', '7933965', 'jos12ue21@gmail.com', 'Sucre', 0, '2017-08-31 18:47:35', 'participante', '0000-00-00 00:00:00', 0),
(600, 'SAUL', 'GRIMALDIS PEÑAS', '10530624', 'saugrimaldis@gmail.com', 'POTOSI', 0, '2017-08-31 18:55:03', 'participante', '0000-00-00 00:00:00', 0),
(601, 'Josué Miguel', 'Canaviri Martinez', '13090614', 'jcanaviri20@gmail.com', 'Sucre', 0, '2017-08-31 19:16:18', 'participante', '0000-00-00 00:00:00', 0),
(602, 'Yhoel Felipe', 'Burga Campos', '7087350', 'yhoelburgacampos@gmail.com', 'La Paz', 0, '2017-08-31 19:28:27', 'participante', '0000-00-00 00:00:00', 0),
(603, 'Adrian Giovany', 'Nina Kantuta', '10916859 LP', 'djadrian247@gmail.com', 'La Paz', 0, '2017-08-31 19:31:45', 'participante', '0000-00-00 00:00:00', 0),
(604, 'Abett Levy', 'Hilarion Juturi', '6689729', 'arabettec12@gmail.com', 'Sucre', 0, '2017-08-31 19:34:44', 'participante', '0000-00-00 00:00:00', 0),
(605, 'Wilber', 'Barcaya Muruchi', '7483769', 'wilberbarcaya2@gmail.com', 'Sucre', 0, '2017-08-31 19:35:17', 'participante', '0000-00-00 00:00:00', 0),
(606, 'Jose Elias', 'Franco Ibarra', '10636240', 'ulisesdiazronaldo17@gmail.com', 'Sucre', 0, '2017-08-31 19:45:25', 'participante', '0000-00-00 00:00:00', 0),
(607, 'JOSE GAEL', 'CHOQUE SERRANO', '7538396', 'gaelelpapi@gmail.com', 'Sucre', 0, '2017-08-31 20:19:41', 'participante', '0000-00-00 00:00:00', 0),
(608, 'Julio Andres', 'Duran Kespi', '12804343', 'andresito11022013.jadk@gmail.com', 'Sucre', 0, '2017-08-31 20:21:04', 'participante', '0000-00-00 00:00:00', 0),
(609, 'Sergio Joaquin', 'Fernandez Marza', '4476680', 'jeral.sergio@gmail.com', 'Cochabamba', 0, '2017-08-31 21:48:29', 'participante', '0000-00-00 00:00:00', 0),
(610, 'Erwing', 'Choquerive Quispe', '12396623', 'choquerive.erwing123@gmail.com', 'Sucre', 0, '2017-08-31 21:48:48', 'participante', '0000-00-00 00:00:00', 0),
(611, 'Kevin Joaquín', 'Diaz Colque', '10307164', 'kevinjoamonster@gmail.com', 'Sucre', 0, '2017-08-31 21:48:56', 'participante', '0000-00-00 00:00:00', 0),
(612, 'Jhonatan David', 'Condarco Cuellar', '8679461', 'cjhon0701@gmail.com', 'Cochabamba', 0, '2017-08-31 21:49:20', 'participante', '0000-00-00 00:00:00', 0),
(613, 'Kenny Alvaro', 'Ecos Lugo', '12898510', 'alvaroecoslugo@gmail.com', 'Sucre', 0, '2017-08-31 22:04:44', 'participante', '0000-00-00 00:00:00', 0),
(614, 'Casilda', 'Aguilar Flores', '10524814', 'lpc.kassy.2012@gmail.com', 'Sucre', 0, '2017-08-31 22:06:30', 'participante', '0000-00-00 00:00:00', 0),
(615, 'Beni', 'peñal', '121212121', 'pxk75377@sjuaq.com', 'Villa Montes', 0, '2017-08-31 22:06:44', 'participante', '0000-00-00 00:00:00', 0),
(616, 'Daniel', 'Mendoza Tito', '6894551', 'danielmt1987@hotmail.com', 'La Paz', 0, '2017-08-31 22:32:34', 'participante', '0000-00-00 00:00:00', 0),
(617, 'Félix Alejandro', 'Zelaya Orellana', '7513483', 'fazogato@hotmail.com', 'Sucre', 0, '2017-08-31 23:11:48', 'participante', '0000-00-00 00:00:00', 0),
(618, 'Sbieth Anahí', 'Arandia André', '72700301', 'sbieth.1anahi@gmail.com', 'Sucre', 0, '2017-08-31 23:22:13', 'participante', '0000-00-00 00:00:00', 0),
(619, 'Heidy', 'Tinuco Montes', '5641023', 'heidytinuco123@gmail.com', 'Sucre', 0, '2017-09-01 00:00:07', 'participante', '0000-00-00 00:00:00', 0),
(620, 'Eddy Jhon', 'Peñaranda Arispe', '8598887', 'edpe1992@gmail.com', 'Potosí', 0, '2017-09-01 00:43:19', 'participante', '0000-00-00 00:00:00', 0),
(621, 'jhonny Ivan', 'Colque Ajomado', '10566976', 'jhonny_ivan365@hotmail.com', 'Sucre', 0, '2017-09-01 01:22:49', 'participante', '0000-00-00 00:00:00', 0),
(622, 'JOSE FRANCISCO', 'MENDOZA RIOS', '10561504', 'panchitoanahi123@gmail.com', 'Potosí', 0, '2017-09-01 01:32:53', 'participante', '0000-00-00 00:00:00', 0),
(623, 'Daniel Inti Alberto', 'Choque Mamani', '7230411', 'danielintialberto19@gmail.com', 'Sucre', 0, '2017-09-01 02:01:26', 'participante', '0000-00-00 00:00:00', 0),
(624, 'Jose David Harold', 'Illanes Velasquez', '4894112 L.P.', 'joseiv150293@gmail.com', 'La Paz', 0, '2017-09-01 02:59:00', 'participante', '0000-00-00 00:00:00', 0),
(625, 'juan fernando', 'martinez condori', '10537078', 'fercho19cabron@gmail.com', 'Potosí', 0, '2017-09-01 03:31:41', 'participante', '0000-00-00 00:00:00', 0),
(626, 'fatima fabiola', 'bravo colque', '8597414', 'fati_fabiola_15@hotmail.com', 'Potosí', 0, '2017-09-01 03:37:21', 'participante', '0000-00-00 00:00:00', 0),
(627, 'Marlene Rocio', 'Zarco Silvestre', '9895829', 'mrzsjlnp@gmail.com', 'La Paz', 0, '2017-09-01 03:45:01', 'participante', '0000-00-00 00:00:00', 0),
(628, 'Américo Itamar', 'Echalar Guzman', '7552577', 'americo.ieg@gmail.com', 'Sucre', 0, '2017-09-01 05:01:00', 'participante', '0000-00-00 00:00:00', 0),
(629, 'Edgar', 'Mollo Flores', '6717686', 'molloemf@gmail.com', 'Sucre', 0, '2017-09-01 11:05:19', 'participante', '0000-00-00 00:00:00', 0),
(630, 'Edson', 'Mollo Flores', '10571412', 'emollo37@gmail.com', 'Sucre', 0, '2017-09-01 11:07:51', 'participante', '0000-00-00 00:00:00', 0),
(631, 'Alejandra Veronica', 'Terceros Arcani', '9202995', 'alesa9202995@gmail.com', 'Sucre', 0, '2017-09-01 11:08:55', 'participante', '0000-00-00 00:00:00', 0),
(632, 'Jose Mauricio', 'Bazagoitia Ayllon', '128344771', 'josemauicio36@gmail.com', 'Sucre', 0, '2017-09-01 11:58:50', 'participante', '0000-00-00 00:00:00', 0),
(633, 'Cristofer', 'Cespedes Padilla', '12802598', 'CPcristofer21@hotmil.com', 'Sucre', 0, '2017-09-01 12:22:31', 'participante', '0000-00-00 00:00:00', 0),
(634, 'Felipe', 'Flores Flores', '10391109', 'felipe.ff61.ff@gmail.com', 'Sucre', 0, '2017-09-01 12:26:11', 'participante', '0000-00-00 00:00:00', 0),
(635, 'Fernando', 'Barrero Bolling', '7586194', 'ferchini.enfin@gmail.com', 'Sucre', 0, '2017-09-01 13:01:00', 'participante', '0000-00-00 00:00:00', 0),
(636, 'Jose Mauricio', 'Bazagoitia Ayllon', '12834771', 'josemauriciobazagoitia2@gmail.com', 'Sucre', 0, '2017-09-01 13:01:32', 'participante', '0000-00-00 00:00:00', 0),
(637, 'Juan Carlos', 'Maldonado Mamani', '10381100', 'mvj.carlos15@gmail.com', 'Sucre', 0, '2017-09-01 13:03:30', 'participante', '0000-00-00 00:00:00', 0),
(638, 'Hey Dika', 'Jarillo poma', '5715535', 'heydikacaper@gmail.com', 'Cobija', 0, '2017-09-01 13:08:28', 'participante', '0000-00-00 00:00:00', 0),
(639, 'Gilda Noelia', 'Mamani Mendez', '8523615', 'gildamamani38@gmail.com', 'Potosi', 0, '2017-09-01 13:08:49', 'participante', '0000-00-00 00:00:00', 0),
(640, 'Cinthya', 'Layme Fajardo', '5649721', 'cinthya.028.lf@gmail.com', 'Sucre', 0, '2017-09-01 13:15:56', 'participante', '0000-00-00 00:00:00', 0),
(641, 'Christian Jhonny', 'Rojas Calvimontes', '7503911', 'thebestcrodal@gmail.com', 'Sucre', 0, '2017-09-01 13:26:28', 'participante', '0000-00-00 00:00:00', 0),
(642, 'Emilia', 'Gamarra Balas', '7485566', 'emigb15@gmail.com', 'Sucre', 0, '2017-09-01 13:31:27', 'participante', '0000-00-00 00:00:00', 0),
(643, 'Maribel', 'Arando Benavides', '10460793', 'marisitabenavides9@gmail.com', 'Potosi', 0, '2017-09-01 13:46:56', 'participante', '0000-00-00 00:00:00', 0),
(644, 'Anarely', 'Quispe Cruz', '8512531', 'quispeana761@gmail.com', 'Potosi', 0, '2017-09-01 13:51:13', 'participante', '0000-00-00 00:00:00', 0),
(645, 'Juan Marcos', 'Tola Sanchez', '11324314', 'marcos.jhono97@gmail.com', 'Sucre', 0, '2017-09-01 13:57:17', 'participante', '0000-00-00 00:00:00', 0),
(646, 'Carla Lorena', 'Maija Apase', '5616631', 'carlalorenamaija20@gmail.com', 'Sucre', 0, '2017-09-01 14:21:54', 'participante', '0000-00-00 00:00:00', 0),
(647, 'José Marcelo', 'Estrada', '10577352', 'byjosma@gmail.com', 'Potosí', 0, '2017-09-01 14:35:56', 'participante', '0000-00-00 00:00:00', 0),
(648, 'Josseline Alejandra', 'Miranda Laura', '10365614', 'josselinemiranda4@gmail.com', 'Sucre', 0, '2017-09-01 14:37:38', 'participante', '0000-00-00 00:00:00', 0),
(649, 'Ilsen', 'Romero caraballo', '7578870', 'terryselt@gmail.com', 'Sucre', 0, '2017-09-01 14:50:21', 'participante', '0000-00-00 00:00:00', 0),
(650, 'LILIANA', 'CUIZA VILLCA', '7526840', 'liliana2000cv@gmail.com', 'Sucre', 0, '2017-09-01 14:55:51', 'participante', '0000-00-00 00:00:00', 0),
(651, 'Grecia', 'Medina Condori', '6947075', 'grecia6660@gmail.com', 'Sucre', 0, '2017-09-01 14:57:15', 'participante', '0000-00-00 00:00:00', 0),
(652, 'Esther Alejandra', 'Limachi Condori', '9870223', 'avrilalejandralimahi@gmail.com', 'La Paz', 0, '2017-09-01 15:00:00', 'participante', '0000-00-00 00:00:00', 0),
(653, 'Eddy Jhoel', 'Quispe Diaz', '8533829', 'eddy.jhoel14@gmail.com', 'Potosí', 0, '2017-09-01 15:07:44', 'participante', '0000-00-00 00:00:00', 0),
(654, 'Jasmina Jael', 'Huallpa Oyola', '10638460', 'jaelh80@gmail.com', 'Sucre', 0, '2017-09-01 15:15:55', 'participante', '0000-00-00 00:00:00', 0),
(655, 'Juan Jose', 'Perez Yucra', '8167894', 'juanjoseperez97@gmail.com', 'Sucre', 0, '2017-09-01 15:20:13', 'participante', '0000-00-00 00:00:00', 0),
(656, 'Delma Carolina', 'Oni fernandez', '12468863', 'dcaroline_oni@hotmail.com', 'Sucre', 0, '2017-09-01 15:52:26', 'participante', '0000-00-00 00:00:00', 0),
(657, 'Pamela', 'Ecos Quispe', '12396986', 'mela121098@gmail.com', 'Sucre', 0, '2017-09-01 15:56:21', 'participante', '0000-00-00 00:00:00', 0),
(658, 'Mayra', 'Barrionuevo Cayo', '7527118', 'mayracayo49@gmail.com', 'Sucre', 0, '2017-09-01 16:15:24', 'participante', '0000-00-00 00:00:00', 0),
(659, 'CRISTIAN GUSTABO', 'MARTINEZ FLORES', '12346579', 'chrizgustabo7891011@gmail.com', 'Sucre', 0, '2017-09-01 16:33:08', 'participante', '0000-00-00 00:00:00', 0),
(660, 'jerson giovanni', 'zeballos venegas', '9165701', 'jersonzeballosv@gmail.com', 'potosi', 0, '2017-09-01 16:47:38', 'participante', '0000-00-00 00:00:00', 0),
(661, 'Gary David', 'Guzmán Muñoz', '10917763', 'gary.2810.dav@gmail.com', 'Sucre', 0, '2017-09-01 17:07:10', 'participante', '0000-00-00 00:00:00', 0),
(662, 'Juan Jose', 'Alandia Gonzales', '3655517', 'juan_j_19@hotmail.com', 'Sucre', 0, '2017-09-01 17:27:13', 'participante', '0000-00-00 00:00:00', 0),
(663, 'giancarlo', 'pasquale', '9125990', 'giancarlopasquale73@gmail.com', 'Sucre', 0, '2017-09-01 17:48:16', 'participante', '0000-00-00 00:00:00', 0),
(664, 'DANILO ANGEL', 'TITO RODRÍGUEZ', '8511184', 'danilot390@gmail.com', 'Potosí', 0, '2017-09-01 18:00:36', 'participante', '0000-00-00 00:00:00', 0),
(665, 'ABRAHAN', 'VILLCA FERNANDEZ', '10302672', 'yhohylove@gmail.com', 'SUCRE', 0, '2017-09-01 18:25:23', 'participante', '0000-00-00 00:00:00', 0),
(666, 'BORIS', 'FERNANDEZ VILLCA', '7508015', 'borisfer50@gmail.com', 'Sucre', 0, '2017-09-01 18:29:37', 'participante', '0000-00-00 00:00:00', 0),
(667, 'Darwin Michael', 'Acuña Carlos', '7509605', 'darwin.michael.a.carlos@gmail.com', 'Sucre', 0, '2017-09-01 18:30:38', 'participante', '0000-00-00 00:00:00', 0),
(668, 'Ani Vanesa', 'Quispe Alcoba', '10400184', 'aniquispe282@gmail.com', 'Sucre', 0, '2017-09-01 18:36:25', 'participante', '0000-00-00 00:00:00', 0),
(669, 'DANYA', 'NINA COA', '7496188', 'nina.danya.19@gmail.com', 'Sucre', 0, '2017-09-01 18:37:52', 'participante', '0000-00-00 00:00:00', 0),
(670, 'LUIS DANIEL', 'CONDORI LLANQUI', '10408867', 'PELUZIN123@GMAIL.COM', 'SUCRE', 0, '2017-09-01 18:37:55', 'participante', '0000-00-00 00:00:00', 0),
(671, 'Test10', 'Test10', 'Test10', 'test10@gmail.com', 'Test1', 0, '2017-09-01 18:48:37', 'participante', '0000-00-00 00:00:00', 0),
(672, 'Helmer Fellman', 'Mendoza Jurado', '4139789', 'helmer.mendoza@upds.edu.bo', 'Tarija', 0, '2017-09-01 18:52:29', 'participante', '0000-00-00 00:00:00', 0),
(673, 'HAROL ADDIEL', 'HERRERA MENDEZ', '12803610', 'CHIQITUMAN@GMAIL.COM', 'SUCRE', 0, '2017-09-01 18:52:46', 'participante', '0000-00-00 00:00:00', 0),
(674, 'test11', 'test11', 'test11', 'test11@gmail.com', 'test11', 0, '2017-09-01 18:54:53', 'participante', '0000-00-00 00:00:00', 0),
(675, 'Erwin', 'Erwin', '11111111', 'erwin@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-09-01 18:59:53', 'participante', '0000-00-00 00:00:00', 0),
(676, 'Miguel Angel', 'Lazo Calcina', '8537347', 'miguelito.ang.lazo@gmail.com', 'Sucre', 0, '2017-09-01 19:00:40', 'participante', '0000-00-00 00:00:00', 0),
(677, 'Edmundo', 'Salazar Alarcón', '7507789', 'edmundosalazarpay@gmail.com', 'Sucre', 0, '2017-09-01 19:13:42', 'participante', '0000-00-00 00:00:00', 0),
(678, 'Adolfo', 'Chungara Pinto', '6993076 lp', 'chungarpinto@gmail.com', 'La Paz', 0, '2017-09-01 19:22:22', 'participante', '0000-00-00 00:00:00', 0),
(679, 'Jhonatan', 'Hurtado Flores', '10507215', 'jhonhurtado9.jhf@gmail.com', 'Sucre', 0, '2017-09-01 19:29:42', 'participante', '0000-00-00 00:00:00', 0),
(680, 'Wilson Wilder', 'Mendoza Copa', '10325319', 'wildercrk68@gmail.com', 'Sucre', 0, '2017-09-01 19:46:25', 'participante', '0000-00-00 00:00:00', 0),
(681, 'Henry', 'Galvan Velasquez', '5668618', 'galvan.sistelec.rockgelion@gmail.com', 'Sucre', 0, '2017-09-01 19:49:30', 'participante', '0000-00-00 00:00:00', 0),
(682, 'Jose Guadalupe', 'Caba Alarcon', '12609506', 'jhiosekin123@hotmail.com', 'Sucre', 0, '2017-09-01 19:50:57', 'participante', '0000-00-00 00:00:00', 0),
(683, 'Sandro Rodrigo', 'Torrez Michel', '13250306', 'torrezmichelsandro16@gmail.com', 'Sucre', 0, '2017-09-01 19:51:46', 'participante', '0000-00-00 00:00:00', 0),
(684, 'Marlene', 'Yucra Seña', '7494173', 'marlenyucrasena123@gmail.com', 'Sucre', 0, '2017-09-01 19:56:40', 'participante', '0000-00-00 00:00:00', 0),
(685, 'Giovanna Marcia', 'Ibañez Mendoza', '5033018', 'gimmc@hotmail.com', 'Sucre', 0, '2017-09-01 19:56:56', 'participante', '0000-00-00 00:00:00', 0),
(686, 'Yufan', 'Condori leon', '9054159', 'gogeta9000.ycl@gmail.com', 'Sucre', 0, '2017-09-01 19:58:52', 'participante', '0000-00-00 00:00:00', 0),
(687, 'Brayan', 'Cardenas zarate', '10333909', 'chino_13_cz@hotmail.com', 'Sucre', 0, '2017-09-01 20:01:18', 'participante', '0000-00-00 00:00:00', 0),
(688, 'Juan Victor', 'Bascope Castro', '26-1995', 'juan.victor.bascope.castro@gmail.com', 'Sucre', 0, '2017-09-01 20:01:51', 'participante', '0000-00-00 00:00:00', 0),
(689, 'Karla Paola', 'Rodas Arce', '12932064', 'karliittagermanotta@gmail.com', 'Sucre', 0, '2017-09-01 20:07:43', 'participante', '0000-00-00 00:00:00', 0),
(690, 'MIJAEL JHONATHAN', 'JORGE MONTEALEGRE', '8506625', 'mijaelmail.com@gmail.com', 'POTOSI', 0, '2017-09-01 20:11:32', 'participante', '0000-00-00 00:00:00', 0),
(691, 'jhoel', 'calani gorena', '10387667', 'jchaolealni@gmail.com', 'Sucre', 0, '2017-09-01 20:16:07', 'participante', '0000-00-00 00:00:00', 0),
(692, 'Perito de los palotes', 'Palotes', '1234560', 'abc@gmail.com', 'Sucre', 0, '2017-09-01 20:16:08', 'participante', '0000-00-00 00:00:00', 0),
(693, 'Mauricio', 'Lescano Fernandez', '7538000', 'mauriciolescano188@gmail.com', 'Sucre', 0, '2017-09-01 20:19:44', 'participante', '0000-00-00 00:00:00', 0),
(694, 'Rodrigo', 'Portillo  vargas', '10638984', 'rodropor@outlook.com', 'Sucre', 0, '2017-09-01 20:21:34', 'participante', '0000-00-00 00:00:00', 0),
(695, 'Josue', 'Peducasse Carranza', '10391111', 'josuepc012899@gmail.com', 'Sucre', 0, '2017-09-01 20:24:19', 'participante', '0000-00-00 00:00:00', 0),
(696, 'gissel', 'leon', '7568353', 'gissel320_alex_a@gmail.com', 'Sucre', 0, '2017-09-01 20:36:03', 'participante', '0000-00-00 00:00:00', 0),
(697, 'Samuel', 'Meguillanes Javier', '7513413', 'sak.aceen@gmail.com', 'Sucre', 0, '2017-09-01 20:49:58', 'participante', '0000-00-00 00:00:00', 0),
(698, 'Felix Antonio', 'Flores Yampara', '5663573', 'felix.antonio.flores.26@gmail.com', 'Sucre', 0, '2017-09-01 20:56:54', 'participante', '0000-00-00 00:00:00', 0),
(699, 'Diego Armando', 'Párraga Ortuste', '7480586', 'razor_d13@hotmail.es', 'Sucre', 0, '2017-09-01 21:05:15', 'participante', '0000-00-00 00:00:00', 0),
(700, 'ADRIANA', 'MORODIAS AYARACHI', '8522746', 'adrianatuamix@gmail.com', 'Potosí', 0, '2017-09-01 21:10:46', 'participante', '0000-00-00 00:00:00', 0),
(701, 'Arnold', 'Herrera Chambi', '8505997', 'arn_14_@hotmail.com', 'Sucre', 0, '2017-09-01 21:12:20', 'participante', '0000-00-00 00:00:00', 0),
(702, 'Einar Noel', 'Herrera Chambi', '8505995', 'noe_e_354@hotmail.com', 'Sucre', 0, '2017-09-01 21:15:22', 'participante', '0000-00-00 00:00:00', 0),
(703, 'Orlando', 'Roque Castro', '12397582', 'orlandoroquecastro1@gmail.com', 'Sucre', 0, '2017-09-01 21:37:49', 'participante', '0000-00-00 00:00:00', 0),
(704, 'Wilson Alfonzo', 'Medina Chipana', '7208003', 'wilson.wmc1722@gmail.com', 'Tarija', 0, '2017-09-01 21:58:03', 'participante', '0000-00-00 00:00:00', 0),
(705, 'Cintihia', 'Caña Aldana', '35-2871', 'cabaaldanacinthla@gmail.com', 'Sucre', 0, '2017-09-01 21:58:33', 'participante', '0000-00-00 00:00:00', 0),
(706, 'Santos Javier', 'Avila Avila', '7528141', 'javier.avila.sj@gmail.com', 'Sucre', 0, '2017-09-01 22:00:42', 'participante', '0000-00-00 00:00:00', 0),
(707, 'Raul Alberto', 'Pary Talavera', '8513703', 'shuren_666@hotmail.com', 'Sucre', 0, '2017-09-01 22:00:50', 'participante', '0000-00-00 00:00:00', 0),
(708, 'Jose Fernando', 'Alfaro Ayzama', '8617537', 'alfa6547@gmail.com', 'Sucre', 0, '2017-09-01 22:01:53', 'participante', '0000-00-00 00:00:00', 0),
(709, 'Miguel Angel', 'Gutierrez Leandro', '6699498', 'xperiaj19922012@gmail.com', 'Potosí', 0, '2017-09-01 22:07:07', 'participante', '0000-00-00 00:00:00', 0),
(710, 'Boris Mario', 'Caba Pérez', '5212997', 'borismcaba@gmail.com', 'Cochabamba', 0, '2017-09-01 22:22:55', 'participante', '0000-00-00 00:00:00', 0),
(711, 'Franz leonardo', 'Ribera saavedra', '9052135', 'franzribera12@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-09-01 22:23:50', 'participante', '0000-00-00 00:00:00', 0),
(712, 'Mariana Jhoselin', 'Apaza Mamani', '10381713', 'mariana.jh.apaza.m@gmail.com', 'Sucre', 0, '2017-09-01 22:33:53', 'participante', '0000-00-00 00:00:00', 0),
(713, 'gilberto santos', 'avalos marin', '9627002', 'wilber75050@gmail.com', 'santa cruz', 0, '2017-09-01 22:35:31', 'participante', '0000-00-00 00:00:00', 0),
(714, 'Norma', 'Mamani Flores', '7561989', 'nsis6201@gmail.com', 'Sucre', 0, '2017-09-01 22:36:04', 'participante', '0000-00-00 00:00:00', 0),
(715, 'Jenifer', 'Churqui Nina', '12610724', 'jeniferchurquinina3@gmail.com', 'Sucre', 0, '2017-09-01 22:37:09', 'participante', '0000-00-00 00:00:00', 0),
(716, 'Sergio Raul', 'Vilches Peñaranda', '6739607-LP', 'sergiovilchesp@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-09-01 23:01:28', 'participante', '0000-00-00 00:00:00', 0),
(717, 'fanny karen', 'flores murillo', '12427830', 'fanny.fkm2015@gmail.com', 'sucre', 0, '2017-09-01 23:36:34', 'participante', '0000-00-00 00:00:00', 0),
(718, 'yhoselin', 'torrez mollo', '7060479', 'yhostorrezm@gmail.com', 'La Paz', 0, '2017-09-01 23:42:11', 'participante', '0000-00-00 00:00:00', 0),
(719, 'mijael deymar', 'mamani bacarreza', '12515236', 'deymarbacarreza@gmail.com', 'La Paz', 0, '2017-09-01 23:45:22', 'participante', '0000-00-00 00:00:00', 0),
(720, 'Alvaro Daniel', 'Rocha Rocha', '10328231', 'alvarodaniel_r@hotmail.com', 'Sucre', 0, '2017-09-01 23:48:03', 'participante', '0000-00-00 00:00:00', 0),
(721, 'Dracen Kevin', 'Romero Rivero', '6661000', 'Drake_dkrr_15_@hotmail.com', 'Potosí', 0, '2017-09-02 00:15:30', 'participante', '0000-00-00 00:00:00', 0),
(722, 'Cristian Manuel', 'Solis Guerra', '10401716', 'manuel96solis@gmail.com', 'Sucre', 0, '2017-09-02 00:20:50', 'participante', '0000-00-00 00:00:00', 0),
(723, 'William Elmer', 'Ortiz Méndez', '10342220', 'william.e.ortiz.mendez@gmail.com', 'Sucre', 0, '2017-09-02 00:46:12', 'participante', '0000-00-00 00:00:00', 0),
(724, 'José Guadalupe', 'Calizaya Mamani', '8654276', 'jcalizaya9@gmail.com', 'Sucre', 0, '2017-09-02 00:48:49', 'participante', '0000-00-00 00:00:00', 0),
(725, 'Brenda Kely', 'Mita Martinez', '10394573', 'brendakelymita@gmail.com', 'chuquisaca', 0, '2017-09-02 01:07:29', 'participante', '0000-00-00 00:00:00', 0),
(726, 'test11', 'test11', 'test12', 'test12@gmail.com', 'test11', 0, '2017-09-02 01:08:39', 'participante', '0000-00-00 00:00:00', 0),
(727, 'test13', 'test13', 'test13', 'test13@gmail.com', 'test13', 0, '2017-09-02 01:10:06', 'participante', '0000-00-00 00:00:00', 0),
(728, 'David Ronaldo', 'Juarez Zurita', '8888381', 'djZurita.ficct@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-09-02 01:12:51', 'participante', '0000-00-00 00:00:00', 0),
(729, 'Andres Percy', 'Fuentes Manzaneda', '10530564', 'eltrocador1@gmail.com', 'Potosí', 0, '2017-09-02 01:39:17', 'participante', '0000-00-00 00:00:00', 0),
(730, 'Angel', 'Pacheco', '13124058', 'AngelPacheco897@gmail.com', 'Sucre', 0, '2017-09-02 01:44:57', 'participante', '0000-00-00 00:00:00', 0),
(731, 'Marisol', 'Loredo Candi', '12456066', 'Marisolloredo231@gmail.com', 'Sucre', 0, '2017-09-02 01:53:57', 'participante', '0000-00-00 00:00:00', 0),
(732, 'Andrez Eduardo', 'Yucra Gutierrez', '12353332', 'andrez.gt7@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-09-02 02:07:07', 'participante', '0000-00-00 00:00:00', 0),
(733, 'Carminia', 'Mamani Quispe', '10384843', 'Carmi212mamani@gmail.com', 'Sucre', 0, '2017-09-02 02:18:26', 'participante', '0000-00-00 00:00:00', 0),
(734, 'Erick Americo', 'Guzman Rios', '9450650', 'americo_erick@hotmail.com', 'Sucre', 0, '2017-09-02 02:51:56', 'participante', '0000-00-00 00:00:00', 0),
(735, 'Harold Eduardo', 'Rodriguez Poma', '9171952', 'haroldarok@gmail.com', 'La Paz', 0, '2017-09-02 02:55:47', 'participante', '0000-00-00 00:00:00', 0),
(736, 'Mirko Fernando', 'Romay Ramos', '6700362', 'mirfer.sis@gmail.com', 'Potosi', 0, '2017-09-02 02:56:15', 'participante', '0000-00-00 00:00:00', 0),
(737, 'JANETH', 'HUARACHI ROJAS', '8326644', 'jane.14560@gmail.com', 'La Paz', 0, '2017-09-02 03:14:50', 'participante', '0000-00-00 00:00:00', 0),
(738, 'Luis Alejandro', 'Mamani Alvarez', '6595501', 'papuchyto@gmail.com', 'Sucre', 0, '2017-09-02 03:33:26', 'participante', '0000-00-00 00:00:00', 0),
(739, 'Narciso', 'Aguilar Mallon', '6662449', 'nachoam361@gmail.com', 'Potosi', 0, '2017-09-02 03:36:51', 'participante', '0000-00-00 00:00:00', 0),
(740, 'JUAN MANUEL', 'ANTEZANA MONTOYA', '6166537', 'juanmanuelantezanamontoya@gmail.com', 'La Paz', 0, '2017-09-02 03:44:56', 'participante', '0000-00-00 00:00:00', 0),
(741, 'Osmar', 'Angulo Hermosa', '7899298', 'osmar_sanjose@hotmail.com', 'Cochabamba', 0, '2017-09-02 03:48:03', 'participante', '0000-00-00 00:00:00', 0),
(742, 'Mireya Milenka', 'Martínez Miranda', '8525945', 'mireyamilenka@gmail.com', 'Potosí', 0, '2017-09-02 13:09:19', 'participante', '0000-00-00 00:00:00', 0),
(743, 'Luzmila Jhaneth', 'Carlos Acuña', '10379190', 'luz99jhaneth@gmail.com', 'Sucre', 0, '2017-09-02 14:55:54', 'participante', '0000-00-00 00:00:00', 0),
(744, 'Edwin', 'Calle Perez', '12835636', 'edwincalle-@hotmail.com', 'Sucre', 0, '2017-09-02 16:00:09', 'participante', '0000-00-00 00:00:00', 0),
(745, 'Franz Ronald', 'Soria Colque', '14032582', 'sistemasjheremi@gmail.com', 'Sucre', 0, '2017-09-02 16:03:10', 'participante', '0000-00-00 00:00:00', 0),
(746, 'Adhemar Jhonny', 'Lapaca Callaguara', '12898004', 'adhemar321._@hotmail.com', 'sucre', 0, '2017-09-02 16:59:16', 'participante', '0000-00-00 00:00:00', 0),
(747, 'Lizeth Erlinda', 'Perez Calderon', '10350858', 'lizipeca10@gmail.com', 'Sucre', 0, '2017-09-02 17:17:03', 'participante', '0000-00-00 00:00:00', 0),
(748, 'Luis Samuel', 'Pari Nava', '12803767', 'dialgaluis@gmail.com', 'Sucre', 0, '2017-09-02 17:51:14', 'participante', '0000-00-00 00:00:00', 0),
(749, 'Ronald Frank', 'Patzi Poma', '9121620', 'rpomap@gmail.com', 'la paz', 0, '2017-09-02 19:12:42', 'participante', '0000-00-00 00:00:00', 0),
(750, 'Daniel Richard', 'Condori Rodriguez', '7377033', 'dan.rcr01@gmail.com', 'Oruro', 0, '2017-09-02 19:34:52', 'participante', '0000-00-00 00:00:00', 0),
(751, 'Patrick Dylan', 'Estrada Chamoso', '12962492', 'suckablood1997@hotmail.com', 'Sucre', 0, '2017-09-02 19:43:34', 'participante', '0000-00-00 00:00:00', 0),
(752, 'Carlos Iván', 'Rocha Rocha', '7496147', 'ivan181192@hotmail.com', 'sucre', 0, '2017-09-02 21:21:16', 'participante', '0000-00-00 00:00:00', 0),
(753, 'Elmer Guido', 'Guzman Equiza', '5741222', 'elmerequiza@hotmail.com', 'Llallagua', 0, '2017-09-02 23:43:01', 'participante', '0000-00-00 00:00:00', 0),
(754, 'Jhoselin', 'Barañado Carranza', '7496310', 'jhose16bc@gmail.com', 'Sucre', 0, '2017-09-03 00:59:36', 'participante', '0000-00-00 00:00:00', 0),
(755, 'René Edwin', 'Villarroel Rubin de Celis', '8878348', 'renetoon13@gmail.com', 'Santa Cruz De La Sierra', 0, '2017-09-03 01:12:17', 'participante', '0000-00-00 00:00:00', 0),
(756, 'Joseline Gabriela', 'Diaz Jimenez', '10307121', 'gabrielyta2@gmail.com', 'Sucre', 0, '2017-09-03 02:01:18', 'participante', '0000-00-00 00:00:00', 0),
(757, 'Jesus', 'Morales Perez', '12845129', 'jesusmoral011096@gmail.com', 'Potosí', 0, '2017-09-03 02:34:13', 'participante', '0000-00-00 00:00:00', 0),
(758, 'Wilbert', 'pinto Chambi', '12346418', 'wilbertpinto71@gmail.com', 'sucre', 0, '2017-09-03 03:30:16', 'participante', '0000-00-00 00:00:00', 0),
(759, 'AMILKAR MIGUEL', 'CHECA MAMANI', '10521625', 'dj_alexito_@hotmail.com', 'Potosí', 0, '2017-09-03 04:03:53', 'participante', '0000-00-00 00:00:00', 0),
(760, 'Damaris Laura', 'Ayala Pari', '12864015', 'damarisayala02@gmail.com', 'La paz', 0, '2017-09-03 04:05:04', 'participante', '0000-00-00 00:00:00', 0),
(761, 'Andres Emilio', 'Gonzales Arcienega', '10349158', 'madshotqq8@gmail.com', 'Sucre', 0, '2017-09-03 12:19:14', 'participante', '0000-00-00 00:00:00', 0),
(762, 'Nector Antonio', 'Carita Valdiviezo', '9795706', 'nector@mozillabolivia.org', 'Santa Cruz de la Sierra', 0, '2017-09-03 14:54:36', 'participante', '0000-00-00 00:00:00', 0),
(763, 'Ramiro Edgar', 'Cayhuara Vargas', '5130777 Pt.', 'simar.edge24.amistad@gmail.com', 'Potosí', 0, '2017-09-03 15:04:03', 'participante', '0000-00-00 00:00:00', 0);

--
-- Disparadores `user`
--
DELIMITER $$
CREATE TRIGGER `delete_user_audit` AFTER DELETE ON `user` FOR EACH ROW INSERT INTO user_aud(id_user, name, last_name, ci, email, 
   city, paid, registration_date, cargo, id_admin, 
   inscription_date, operation) VALUES(OLD.id,OLD.name,OLD.last_name, OLD.ci,OLD.email,OLD.city,OLD.paid,OLD.registration_date,OLD.cargo,
   OLD.id_admin, OLD.inscription_date, 'DELETED')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_user_audit` AFTER INSERT ON `user` FOR EACH ROW INSERT INTO user_aud(id_user, name, last_name, ci, email, 
   city, paid, registration_date, cargo, id_admin, 
   inscription_date, operation) VALUES(NEW.id,NEW.name,NEW.last_name, NEW.ci,NEW.email,NEW.city,NEW.paid,NEW.registration_date,NEW.cargo,
   NEW.id_admin, NEW.inscription_date, 'INSERTED')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_user_audit` AFTER UPDATE ON `user` FOR EACH ROW INSERT INTO user_aud(id_user, name, last_name, ci, email, 
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
  `operation` varchar(13) NOT NULL,
  `date_op` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `user_aud`
--

INSERT INTO `user_aud` (`id`, `id_user`, `name`, `last_name`, `ci`, `email`, `city`, `paid`, `registration_date`, `cargo`, `id_admin`, `inscription_date`, `operation`, `date_op`) VALUES
(8, 133, 'Anahi Denisse', 'Contreras Buenaverez', '9981069', 'anahi.denisse.buena@gmail.com', 'La Paz', 0, '2017-08-14 22:20:04', 'participante', 0, '0000-00-00 00:00:00', 'UPDATED', '2017-09-03 16:25:42');

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
-- Indices de la tabla `student_aud`
--
ALTER TABLE `student_aud`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `user_aud`
--
ALTER TABLE `user_aud`
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
-- AUTO_INCREMENT de la tabla `student_aud`
--
ALTER TABLE `student_aud`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=764;
--
-- AUTO_INCREMENT de la tabla `user_aud`
--
ALTER TABLE `user_aud`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
