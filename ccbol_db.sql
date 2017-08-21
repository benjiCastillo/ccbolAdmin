-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 21-08-2017 a las 15:09:06
-- Versión del servidor: 10.1.13-MariaDB
-- Versión de PHP: 7.0.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ccbol_db`
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `countUser` ()  NO SQL
SELECT COUNT(id) as contador FROM `user`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteUser` (IN `_id_user` INT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
		DELETE FROM user WHERE id=_id_user;
        SELECT 'Registro eliminado exitosamente' as respuesta, 'not' as error;
    ELSE
		SELECT 'Error, no existe el registro' as respuesta, 'yes' as error;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertProfessional` (IN `_name` VARCHAR(50), IN `_last_name` VARCHAR(80), IN `_ci` VARCHAR(13), IN `_email` VARCHAR(50), IN `_city` VARCHAR(35), IN `_professional_degree` VARCHAR(75))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertStudent` (IN `_name` VARCHAR(50), IN `_last_name` VARCHAR(80), IN `_ci` VARCHAR(13), IN `_email` VARCHAR(50), IN `_city` VARCHAR(35), IN `_college` VARCHAR(75), IN `_career` VARCHAR(75))  BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `listEvent` ()  BEGIN
	IF(SELECT EXISTS(SELECT * FROM event))THEN
		SELECT ev.id, ev.title, ev.description, ev.date, ev.date, ev.start_time, ex.name, ex.last_name, ex.degree, lo.site, lo.venue FROM event ev INNER JOIN expositor ex ON ev.id_expositor=ex.id INNER JOIN location lo ON ev.id_location=lo.id;
		SELECT 'not' AS error;
    ELSE
		SELECT 'No existen Actividades' AS respuesta, 'yes' AS error; 
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listProfessionals` ()  BEGIN
	IF(SELECT EXISTS( SELECT * FROM user u INNER JOIN professional p ON u.id=p.id_user))THEN
		SELECT u.name, u.last_name, u.ci, u.email, u.city, p.professional_degree, u.paid
		FROM user u INNER JOIN professional p ON u.id=p.id_user;
    ELSE
		SELECT 'No existen registros' as respuesta, 'yes' as error;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listStudent` (IN `_id_user` INT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user where id=_id_user))THEN
		SELECT u.name, u.last_name, u.ci, u.email, u.city, p.professional_degree, u.paid
		FROM user u INNER JOIN professional p ON u.id=p.id_user WHERE u.id=_id_user;
    ELSE
		SELECT 'Error, registro no encontrado' as response, 'yes' as error;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listStudents` ()  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user u INNER JOIN student s ON u.id=s.id_user))THEN
		SELECT u.name, u.last_name, u.ci, u.email, u.city, s.college, s.career, u.paid 
		FROM user u INNER JOIN student s ON u.id=s.id_user;
    ELSE
		SELECT 'No existen registros' as respuesta, 'yes' as error;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listUserBc` (IN `_id_user` INT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			SELECT u.name, u.last_name, u.ci, u.email, u.city, u.paid, s.college, s.career 
            FROM user u INNER JOIN student s ON u.id=s.id_user WHERE u.id=_id_user;
		ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `listUserCi` (IN `_ci` VARCHAR(13))  BEGIN
DECLARE _id_user INT;
	IF(SELECT EXISTS(SELECT * FROM user WHERE ci=_ci))THEN
		SET _id_user=(SELECT id FROM user WHERE ci=_ci);
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			SELECT u.name, u.last_name, u.ci, u.email, u.city, u.paid, s.college, s.career 
            FROM user u INNER JOIN student s ON u.id=s.id_user WHERE u.id=_id_user;
		ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `logout` (IN `_id_admin` INT)  BEGIN
DECLARE _started_time TIMESTAMP;
	SET _started_time = (SELECT started_time FROM access_log WHERE id_admin=_id_admin LIMIT 1);
	UPDATE access_log SET finished_time=LOCALTIME() WHERE id_admin=_id_admin and started_time=_started_time;
    SELECT 'Sesión Finalizada' AS respuesta, 'not' as error;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateUser` (IN `_id_user` INT, IN `_name` VARCHAR(50), IN `_last_name` VARCHAR(80), IN `_ci` VARCHAR(13), IN `_email` VARCHAR(50), IN `_city` VARCHAR(35), IN `_paid` TINYINT, IN `_career` VARCHAR(75), IN `_college` TEXT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			UPDATE user SET name=_name, last_name=_last_name, ci=_ci, email=_email, 
			city=_city, paid=_paid WHERE id=_id_user;
			UPDATE student SET college = _college, career=_career WHERE id_user=_id_user;
			SELECT 'Registro actualizado correctamente' as respuesta, 'not' as error;
        ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				UPDATE user SET name=_name, last_name=_last_name, ci=_ci, email=_email, 
				city=_city, paid=_paid WHERE id=_id_user;
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
			UPDATE user SET paid=1 WHERE id=_id_user;
            INSERT INTO inscription(id_admin, id_user) values(_id_admin, _id_user);
			SELECT u.name, u.last_name, u.ci, u.email, u.city, u.paid, s.college, s.career 
            FROM user u INNER JOIN student s ON u.id=s.id_user WHERE u.id=_id_user;
		ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				UPDATE user SET paid=1 WHERE id=_id_user;
                INSERT INTO inscription(id_admin, id_user) values(_id_admin, _id_user);
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `userPaidCi` (IN `_ci` INT, IN `_id_admin` INT)  BEGIN
DECLARE _id_user INT;
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
    SET _id_user=(SELECT id FROM user WHERE ci=_ci);
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			UPDATE user SET paid=1 WHERE id=_id_user;
            INSERT INTO inscription(id_admin, id_user) values(_id_admin, _id_user);
			SELECT u.name, u.last_name, u.ci, u.email, u.city, u.paid, s.college, s.career 
            FROM user u INNER JOIN student s ON u.id=s.id_user WHERE u.id=_id_user;
		ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				UPDATE user SET paid=1 WHERE id=_id_user;
                INSERT INTO inscription(id_admin, id_user) values(_id_admin, _id_user);
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
  `started_time` timestamp NULL DEFAULT NULL,
  `finished_time` timestamp NULL DEFAULT NULL,
  `id_admin` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `access_log`
--

INSERT INTO `access_log` (`id`, `started_time`, `finished_time`, `id_admin`) VALUES
(16, '2017-08-21 04:37:51', '2017-08-21 04:58:01', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `admin`
--

CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `last_name` varchar(75) COLLATE utf8_spanish_ci NOT NULL,
  `count` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `password` varchar(50) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `admin`
--

INSERT INTO `admin` (`id`, `name`, `last_name`, `count`, `password`) VALUES
(1, 'Silvana', 'Gutiérrez', 'silvana', '1234'),
(2, 'Franz', 'Villalpando', 'franz', '1234');

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
-- Estructura de tabla para la tabla `inscription`
--

CREATE TABLE `inscription` (
  `id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_admin` int(11) NOT NULL,
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

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
(5, 'aaaaa'),
(6, 'bbbb');

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
(4, 'asdaws', 'sdwasda'),
(7, '11111', '2222'),
(8, 'kkkkkk', 'lllll'),
(9, 'ppppppp', 'qqqqq');

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
  `registration_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `name`, `last_name`, `ci`, `email`, `city`, `registration_date`, `paid`) VALUES
(4, 'upsa', 'asd', '12517815', '12111@gmail.com', 'Sucre2', '2017-08-19 02:25:30', 0),
(5, 'Erwin', 'Méndez Mejía', '12517815', 'erwinxyz1@gmail.com', 'Sucre', '2017-08-21 02:12:40', 0),
(6, 'Gary', 'Muñoz ', '12154214', 'gary@gmail.com', 'La Paz', '2017-08-21 02:12:40', 0),
(7, 'Amancaya ', 'Iriarte Negrón', '15246585', 'kaya@gmail.com', 'Sucre', '2017-08-21 02:12:40', 0),
(8, 'Laura', 'Risueño', '15263254', 'lau@gmail.com', 'Sucre', '2017-08-21 02:12:40', 0),
(9, 'Andrea', 'Cornejo', '51263554', 'andrea@gmail.com', 'sucre', '2017-08-21 02:12:40', 0);

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
-- Indices de la tabla `inscription`
--
ALTER TABLE `inscription`
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
--
-- AUTO_INCREMENT de la tabla `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
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
-- AUTO_INCREMENT de la tabla `inscription`
--
ALTER TABLE `inscription`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `location`
--
ALTER TABLE `location`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
