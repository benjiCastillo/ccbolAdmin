-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 31-08-2017 a las 05:57:35
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
		SELECT ev.id, ev.title, ev.description, ev.date, ev.date, ev.start_time, ev.finish_time, ex.name, ex.last_name, ex.degree, lo.site, lo.venue FROM event ev INNER JOIN expositor ex ON ev.id_expositor=ex.id INNER JOIN location lo ON ev.id_location=lo.id;
    ELSE
		SELECT 'No existen Actividades' AS respuesta, 'yes' AS error; 
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listExpositors` ()  BEGIN
	IF(SELECT EXISTS(SELECT * FROM expositor))THEN
		SELECT * FROM expositor;
    ELSE
		SELECT 'No existen expositores' as respuesta, 'yes' as error;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listLodging` ()  BEGIN
	IF(SELECT EXISTS(SELECT * FROM lodging))THEN
		SELECT lt.latitude, lt.longitude, lt.site, lt.venue, lt.description, ld.simple_price, ld.double_price, ld.triple_price, ld.includes, ld.telephone  FROM location lt INNER JOIN lodging ld ON lt.id=ld.id_location;
    ELSE
		SELECT 'No existen Actividades' AS respuesta, 'yes' AS error; 
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listLodgings` ()  BEGIN
	IF(SELECT EXISTS(SELECT * FROM lodging))THEN
		SELECT lt.latitude, lt.longitude, lt.site, lt.venue, lt.description, 
        ld.simple_price, ld.double_price, ld.triple_price, ld.includes, ld.telephone  
        FROM location lt INNER JOIN lodging ld ON lt.id=ld.id_location;
    ELSE
		SELECT 'No existen Hospedajes' AS respuesta, 'yes' AS error; 
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
			SELECT 'not' as error , 1 as type, u.name, u.last_name, u.ci, u.email, u.city, u.paid, s.college, s.career
            FROM user u INNER JOIN student s ON u.id=s.id_user WHERE u.id=_id_user;
		ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				SELECT 'not' as error, 0 as type, u.name, u.last_name, u.ci, u.email, u.city, u.paid, p.professional_degree
				FROM user u INNER JOIN professional p ON u.id=p.id_user WHERE u.id=_id_user;
            ELSE
				SELECT  'yes' as error, 'No se encontró el registro' as respuesta; 
            END IF;
        END IF;
    ELSE
		SELECT  'yes' as error, 'No se encontró el registro' as respuesta; 
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
  `title` text COLLATE utf8_spanish_ci NOT NULL,
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
(5, 'Inscripción. Registro y Acreditación', 'Participantes Ccbol 2017', '2017-09-11', '08:00:00', '17:00:00', 0, 18),
(6, 'El Internet de Todo IdT(IoE)', '¿Que es el Internet de Todo? Personas, Procesos, Datos y Objetos. Conexión de objetos para los consumidores. Programación. Transición de IdT. Conexiones IdT. Creación de modelos de IdT.', '2017-09-11', '17:00:00', '18:30:00', 2, 20),
(7, 'Acto de Inauguración', 'Autoridades, Conferencistas, Invitados Especiales Delegaciones Universitarias Participantes CCBol2017', '2017-10-11', '18:30:00', '20:00:00', 0, 20),
(8, 'Cocktail de Bienvenida', 'Autoridades, Conferencistas, Invitados Especiales', '2017-09-11', '21:00:00', '22:00:00', 0, 19),
(9, 'Fiesta de Bienvenida', 'Delegaciones Universitarias Participantes CCBol2017', '2017-09-11', '22:00:00', '02:00:00', 0, 0),
(10, 'Charla Fundación Jala: “La industria del Software en Bolivia”', '', '2017-09-12', '08:30:00', '09:00:00', 12, 18),
(11, 'Charla Fundación Jala: “Building a framework for automated testing with a multilayer arquitecture using Cucumber JVM and Selenium”', '', '2017-09-12', '09:00:00', '10:30:00', 12, 18),
(12, 'Tutorial 1: “The Constrained Application Protocol (CoAP)“', 'Tutorial enfocado en experimentar CoAP, protocolo a nivel de aplicación diseñado para trabajar con sensores y redes de baja capacidad y que permite una sencilla interconexión con HTTP (Hypertext Transfer Protocol) para una fácil integración en la Web.', '2017-09-12', '09:00:00', '10:30:00', 11, 20),
(13, 'Mesa Redonda 1: “El nuevo paradigma de la educación superior basada en la Internet”', '', '2017-09-12', '09:30:00', '12:30:00', 0, 19),
(14, 'Charla Fundación Jala: “Microservices 101”', 'Javier Roca', '2017-09-12', '10:30:00', '11:30:00', 12, 18),
(15, 'Panel Fundación Jala: “La carrera profesional del Ingeniero de Software”', 'Javier Roca, Silvia Valencia, Fernando Ayala y Raúl Garvizu', '2017-09-12', '11:30:00', '12:30:00', 12, 18),
(16, 'Conferencia 2: “Desarrollo e Implementación incremental de soluciones de infraestructura de IoE/IoT”', 'Los caminos más certeros para lograr el desarrollo e implementación incremental de soluciones de infraestructura de IoE mediante canales de integradores de TI, fabricantes de soluciones de IoT y mediante la infraestructura de los ISP / IXP', '2017-09-12', '11:00:00', '12:30:00', 4, 20),
(17, 'Laboratorio Fundación Jala: “Docker Container Plataform for Windows Server 2016”', 'Fernando Ayala', '2017-10-12', '15:00:00', '16:30:00', 12, 18),
(18, 'Conferencia 3: “Visión por Computador y Boots --- Las Cosas y Objetos hablándote por Internet “', 'Panorama del estado arte en cuanto a software, herramientas y estándares actuales que tienen la finalidad de brindar a sistemas IoT la opción de reconocer objetos, formas y personas, además de poder comunicarse con los usuarios en un lenguaje amigable mediante la creación de boots.', '2017-09-12', '15:00:00', '16:30:00', 10, 20),
(19, 'Mesa de Trabajo Sociedad Científica de Estudiantes de Sistemas e Informática', '', '2017-09-12', '15:00:00', '18:30:00', 0, 19),
(20, 'Laboratorio Fundación Jala: “Behavior Driven Depelopment, a Hands-On in Java”', 'Raul Garvizu', '2017-09-12', '16:30:00', '18:30:00', 0, 18),
(21, 'Conferencia 4: “Impacto social de IoT”.', 'Con la llegada de Internet de las Cosas (IoT), la interconexión de todas las "cosas", la aplicación de nuevos procesos y la generación de volúmenes impensables de datos, Internet deja de ser un servicio de comunicaciones para convertirse en el territorio en el que vivimos. Internet de las Cosas (IoT) transforma las necesidades educativas de una manera innovadora y disruptiva: La mayoría de los empleos que conocemos hoy dejarán de existir en los próximos 10 años. Debemos imaginar el futuro y construir un nuevo sistema educativo para los habitantes de este nuevo territorio; Un sistema educativo que prepara a los ciudadanos de 2030. Empezando hoy.', '2017-09-12', '17:00:00', '18:30:00', 3, 20),
(22, 'Competencia de Robótica', 'Convocatoria especifica', '2017-09-13', '09:00:00', '12:30:00', 0, 18),
(23, 'Conferencia 5:“El rol de la dirección de arte en los dibujos animados y videojuegos”', 'Importancia del Diseño, ilustración, animación y creación de personajes en la dirección de arte de proyectos audiovisuales e interactivos, por medio de una cronología de proyectos y la experiencia profesional de Jorge Cuéllar en la industria argentina de animación y videojuegos.', '2017-09-13', '09:00:00', '10:30:00', 7, 20),
(24, 'Mesa Redonda 2: “Lenguajes de programación apropiados para la enseñanza introductoria de la programación”', '', '2017-09-13', '09:00:00', '12:30:00', 0, 19),
(25, 'Conferencia 6: “Reglas de Oro para ser un buen Game Designer”', 'La labor de un game designer no es nada fácil: debe saber de matemáticas, de informática, de psicología, de interiorismo, de topografía, de arquitectura y por si no fuera poco de nuevas tendencias, estar al día de la competencia y saber combinar el lenguaje del marketing, el del arte y el del desarrollo... vamos, que necesitaríamos unos 30 años para ser unos buenos game designers. Se verán algunos trucos que, aplicados correctamente, pueden llevar a un juego del montón a ser una maquina total de enganchar al jugador y monetizar el producto. Las 15 reglas de oro para ser unos buenos game designers y que esa idea que tanto ha costado concebir se vea plasmada en un producto con garantías de éxito.', '2017-09-13', '11:00:00', '12:30:00', 5, 20),
(26, 'Feria de Innovación Tecnológica Sociedad Científica de Estudiantes de Sistemas e Informática', '', '2017-09-13', '15:00:00', '18:30:00', 0, 19),
(27, 'Conferencia 7: “Los riesgos del IoT”', 'La constante evolución de la informática, ha conllevado al crecimiento y facilidad de acceso a tecnologías programables, con la proliferación del internet de las cosas, la ciencia ficción ha acortado la distancia a la realidad, de dicha forma diversos artefactos del hogar han pasado de ser objetos interactivos, a programables y actualizables mediante la conexión a internet, lo cual ha elevado los riesgos de intrusiones informáticas, incrementándose casos contra la privacidad a niveles jamás antes vistos en la historia. Se señalaran casos sobre los peligros del IoT indicando las soluciones a los problemas relacionados, dando consejos al usuario de cómo implementar controles para su seguridad.', '2017-09-13', '15:00:00', '16:30:00', 8, 20),
(28, 'Taller Especial (1ra Parte): Diseño de personajes y Arte para proyectos animados y videojuegos', 'Taller enfocado en experimentar el proceso creativo en el desarrollo visual para un proyecto original de videojuego o animación, desde la idea, el público objetivo, técnica de animación, estilo visual, concept art y game art. Este taller servirá mucho para aquellos que quieren desarrollar un videojuego propio o ya están en la etapa de desarrollo, entendiendo la importancia de los aspectos visuales.\r\n\r\nParte 1: Diseño para Técnicas de animación (Tradional, pixelart, cut out esqueletal, stopmotion y 3D low y high poly) - Diferencias entre medio audiovisual de un medio interactivo. (Diseño, ilustración, animación y Render) - Estilo visual: Realista, estilizado, cartoon, cute - Características psicológicas y fisiológicas de un personaje: Formas, proporciones, vestuario y Silueta - Diferencia y características entre productos crossmedia y transmedia - Público objetivo: clases de usuarios y clases de juegos - Creación de un brief de un proyecto: referencias y jugabilidad, (concepto: Estilo gráfico, tipo de juego, historia de trasfondo, personalidad del personajes, temática visual de la interface, proporciones y escalas de un nivel prototipo)', '2017-09-13', '15:00:00', '18:30:00', 7, 18),
(29, 'Conferencia 8: “Seguridad embebida, desafíos para el despliegue del IoT”', 'El despliegue de la infraestructura de nodos para Internet de las cosas y su modelo integrado hacia el Internet del Todo, demanda de nuevas estrategias para garantizar la seguridad lo que implica romper un enfoque tradicional, ya que la necesidad de flexibilidad para el acceso de los dispositivos de campo implica un mayor número de vulnerabilidades. Esto plantea preguntas sobre hacia qué modelo apuntar la seguridad para dispositivos pequeños con limitaciones de consumo de potencia, capacidad de procesamiento y memoria, además de que partes de las especificaciones de seguridad se deben de procesar en la niebla (built-in) y que partes deben procesarse en la nube. Se analizaran las nuevas características que demandan los servicios en el Internet del Todo, los desafíos y riesgos que implica para discutir los modelos que se proponen tanto desde el sector corporativo como académico para afrontar estos desafíos, para luego proponer un enfoque de seguridad embebida, y la forma de acelerarla usando hardware configurable.', '2017-09-13', '17:00:00', '18:30:00', 6, 20),
(30, 'Cena de Gala: Autoridades, Conferencistas, Invitados Especiales', '', '2017-09-13', '20:00:00', '22:00:00', 0, 0),
(31, 'Peña Folklórica. Autoridades, Conferencistas, Invitados Especiales', 'Delegaciones Universitarias Participantes CCBol2017', '2017-09-13', '20:00:00', '02:00:00', 0, 0),
(59, 'Presentación Trabajos', 'Convocatoria especifica', '2017-09-14', '09:00:00', '12:30:00', 0, 18),
(60, 'Conferencia 9: “Análisis de ataques informáticos desarrollados con apoyo del IoT”', 'Los ataques mediante dispositivos IoT han sido dinámicos, colapsando internet a nivel mundial, mediante la exposición se explicara cómo se desarrollaron los ataques, que dispositivos son los más empleados para ello, como actúan los criminales cibernéticos, que es un ataques informático. Conocerán cómo funcionan los ataques, método de prevención, principales lugares de alerta de vulnerabilidades de dispositivos, 0 days entre otros.', '2017-09-14', '09:00:00', '10:30:00', 8, 20),
(61, 'Mesa Redonda 3: “Los perfiles del Ingeniero Informático, Ingeniero en Redes e Ingeniero en Ciencias de la Computación”', '', '2017-09-14', '09:00:00', '12:30:00', 0, 19),
(62, 'Conferencia 10: “Estrategia de diseño HLS para el prototipado rápido de alta complejidad”', 'La competitividad de las empresas de tecnología se basa en la reducción del tiempo que tarda un producto desde su concepción hasta su venta, este indicador se conoce como TTM (Time To Market) y su mayor porcentaje se consume en la fase desarrollo del producto; por lo que para lograr menores valores de TTM es necesario enfocar una estrategia de diseño de hardware y software de manera integral donde la descripción del modelo de concepto de una arquitectura se lleve de manera rápida a prototipo. Se analizaran las estrategias de diseño de arquitecturas desde el enfoque tradicional RTL hasta el enfoque basado en alto nivel HL y la forma como esta nueva técnica puede acelerar el proceso de prototipado con las nuevas potencialidades que brindan las herramientas EDA.', '2017-09-14', '11:00:00', '12:30:00', 6, 20),
(63, 'Feria de Innovación Tecnológica Sociedad Científica de Estudiantes de Sistemas e Informática', '', '2017-09-14', '15:00:00', '18:30:00', 0, 19),
(64, 'Tutorial 2: “Crea tu propio videojuego 3D en solamente una hora con unity 5”', 'Que tienen en común Crossy Road, Temple Run, Assassins Creed Identity, Digimon World Next Order o Deux Ex The fall? Además de ser juegos muy conocidos tanto de panorama móvil como de PC y consola, se trata de juegos creados con el popular motor gratuito Unity 5. Y es que hacer un juego en 3D suele involucrar a mucha gente: CD project necesito 365 empleados para the witcher 3, Final Fantasy XV tuvo cerca de 500 durante más de 10 años de desarrollo. Se observará cómo usando Unity 5 se pueden hacer videojuegos al nivel de los antes citados y sin necesidad de tener un estudio grande de juegos ni tantos empleados en nuestro haber.', '2017-09-14', '15:00:00', '16:30:00', 5, 20),
(65, 'Taller Especial (2da Parte): Diseño de personajes y Arte para proyectos animados y videojuegos. Jorge Cuellar Rendón', 'Taller enfocado en experimentar el proceso creativo en el desarrollo visual para un proyecto original de videojuego o animación, desde la idea, el público objetivo, técnica de animación, estilo visual, concept art y game art. Este taller servirá mucho para aquellos que quieren desarrollar un videojuego propio o ya están en la etapa de desarrollo, entendiendo la importancia de los aspectos visuales.\r\n\r\nParte 2: Conceptuales de personajes y entornos (Contexto de la historia y el juego) - Game art, Diseño de personajes y entornos en función a un nivel - Pitchig: Exposición de la propuesta visual para cada proyecto.', '2017-09-14', '15:00:00', '18:30:00', 7, 18),
(66, 'Conferencia 11:“Real Time Web como el sistema nervioso central de IoE“', 'Para poder contar con un universo de dispositivos y personas interconectadas, implica desarrollar plataformas de software donde el flujo de información ocurra en tiempo real. Necesitamos conocer e implementar el stack necesario que nos permita: llegar desde servicios en la nube, a bases de datos y dispositivos de manera óptima. Hoy en día el programar a un nivel de librerías de sockets, es simplemente: Reinventar la rueda. Existen diferentes propuestas a la hora de implementar este tipo de comunicación. ¿Cuáles son las opciones? ¿Oportunidades y debilidades de cada una?, ¿Existen ejemplos exitosos en producción? Estas y otras preguntas se irán respondiendo con la activa participación de la audiencia.', '2017-09-14', '17:00:00', '18:30:00', 9, 20),
(67, 'Presentación Trabajos', 'Convocatoria especifica', '2017-09-15', '09:00:00', '10:30:00', 0, 18),
(68, 'Tutorial 3: “Real Time Web con MongoDB, MeteorJS y Arduino“', 'Tutorial enfocado en experimentar el proceso de construcción de un sistema para el monitoreo remoto de sensores, usando JavaScript, MongoDB y MeteorJS', '2017-09-15', '09:00:00', '10:30:00', 9, 20),
(69, 'Conclusiones y Plenarias', '', '2017-09-15', '09:00:00', '10:30:00', 0, 19),
(70, 'SESIÓN DE CLAUSURA', 'Entrega de certificados, traspaso a la nueva sede CCBOL2018', '2017-09-15', '11:00:00', '12:30:00', 0, 20),
(71, 'Fiesta de Clausura', 'Delegaciones Universitarias Participantes CCBol2017.', '2017-09-15', '22:00:00', '02:00:00', 0, 0);

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
  `linkedin` text COLLATE utf8_spanish_ci NOT NULL,
  `github` text COLLATE utf8_spanish_ci NOT NULL,
  `other` text COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `expositor`
--

INSERT INTO `expositor` (`id`, `name`, `last_name`, `degree`, `company`, `description`, `facebook`, `twitter`, `linkedin`, `github`, `other`) VALUES
(2, 'José Daniel', 'Alberto Constan', '', '', 'Capacitador de Instructores Cisco Networking Academy – CCNA, CCAI, ITQ, CCSI Fundación Proydesa. Buenos Aires Argentina', '', '', 'http://ar.linkedin.com/in/daniel-constán-96349023', '', 'http://www.proydesa.org'),
(3, 'Patricio Raúl', 'Carranza', '', '', 'Analista de IoT (Internet of Things).Consultor en eLearning, mLearning, MOOC Miembro de Internet Society y del steering group de IoT de la Cámara Argentina de Internet.', '', '', 'http://ar.linkedin.com/in/pcarranza', '', 'http://www.carranza.com.ar'),
(4, 'Salvador', 'Crespo', '', '', 'Director Ejecutivo de la Cámara Argentina de Internet Comisión IoT CABASE. Buenos Aires Argentina', '', '', 'http://www.linkedin.com/in/salvador-crespo', '', 'http://www.cabase.org.ar/comision-internet-de-las-cosas-iot-2/'),
(5, 'Juan Gabriel', 'Gomila Salas', '', '', 'CEO en @frogames_sl. Data Scientist, Game Designer & Game Producer, Creador de apps y videojuegos en Frogames. Instructor en un curso online en la creación de apps móviles.', '', '', 'http://www.linkedin.com/in/juan-gabriel-gomila-salas', '', 'http://juangabrielgomila.com/biography/mi-curriculum/'),
(6, 'Carlos Guillermo', 'Bran', '', 'http://www.udb.edu.sv', 'Master en Gerencia de Tecnología y en Investigación en TI. Director Instituto de investigación e innovación en electrónica. Investigador en sistemas embebidos, IoT y controladores inteligentes. Profesor Universidad Don Bosco en El Salvador', '', '', '', '', 'http://citius.usc.es/equipo/investigadores-en-formacion/carlos-guillermo-bran'),
(7, 'Jorge Miguel', 'Cuellar Rendón', '', 'http://www.behance.net/Jorgemcuellar', 'Character Designer / Art Director / Ilustrator / Game Artist.\r\nDirector de Arte para Dibujos animados y Videojuegos en Buenos Aires, Argentina', '', '', 'http://www.linkedin.com/in/jorge-cuellar-rendon', '', 'http://jorgemcuellar.blogspot.com'),
(8, 'Cesar Jesús ', 'Chávez Martínez', '', '', 'Consultor en Seguridad Informática. Analista Forense. Gestor del Proyecto Peruhacking y del Bsides Security Conference Perú. Coordinador Red Latinoamericana de Informática Forense', 'http://www.facebook.com/peruhacking', '', 'http://pe.linkedin.com/in/peruhacking', '', 'http://computo-forense.blogspot.com'),
(9, 'Carlos Alberto', 'Olivera Terrazas', '', '', 'Emprendedor IT, Desarrollador de Ecommerce con plataformas Real Time Web en Bolivia, Universidad Católica Boliviana, Bolivia', '', '', 'http://www.linkedin.com/in/colivera/', '', ''),
(10, 'Said Eduardo', 'Pérez Poppe', '', 'http://www.sis.usfx.edu.bo', 'Ingeniero de Sistemas y Telecomunicaciones, Docente USFX. Instructor Cisco Networking Academy – CCNA. Presidente comité científico Olimpiadas Bolivianas Robótica. Mentor de equipo boliviano de robótica First Global Challenge. 2017', '', '', '', '', 'http://www.saidperez.com'),
(11, 'Oswaldo Gerardo', 'Velázquez Aroni', '', 'http://www.sis.usfx.edu.bo', 'Master en Investigación en IT. Instructor Cisco Networking Academy – CCNA, ITEssentials. Docente y Encargado Departamento de Inteligencia Artificial USFX.', '', '', '', '', ''),
(12, 'Expositores de Fundación Jala', '', '', 'http://www.fundacion-jala.org/', 'Cochabamba - Bolivia', 'http://www.facebook.com/paginafundacionjala/', '', '', '', '');

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
(17, -19.0452305, -65.2602066, 'Hotel la Escondida', 'Calle Junín #445', ''),
(18, -19.0403131, -65.2593577, 'Facultad de Tecnología (U.S.F.X.CH.)', 'Calle Regimiento Campos No 180 y Ricardo Andrade', ''),
(19, -19.0467651, -65.2592129, 'Casa de la cultura universitaria', 'Calle Aniceto Arce N° 28 entre Ravelo y Arenales', ''),
(20, -19.0437931, -65.2654199, 'Teatro Gran Mariscal', 'Calle Km 7, Arenales y Pilinco', '');

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
(4, 'upsa', 'asd', '12517815', '12111@gmail.com', 'Sucre2', '2017-08-19 02:25:30', 1),
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `event`
--
ALTER TABLE `event`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;
--
-- AUTO_INCREMENT de la tabla `expositor`
--
ALTER TABLE `expositor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;
--
-- AUTO_INCREMENT de la tabla `inscription`
--
ALTER TABLE `inscription`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `location`
--
ALTER TABLE `location`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;
--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
