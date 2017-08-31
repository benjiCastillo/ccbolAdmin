-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 31-08-2017 a las 06:24:19
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateUser` (IN `_id_user` INT, IN `_name` VARCHAR(50), IN `_last_name` VARCHAR(80), IN `_ci` VARCHAR(13), IN `_email` VARCHAR(50), IN `_city` VARCHAR(35), IN `_career` VARCHAR(75), IN `_college` TEXT)  BEGIN
	IF(SELECT EXISTS(SELECT * FROM user WHERE id=_id_user))THEN
		IF(SELECT EXISTS(SELECT * FROM student WHERE id_user=_id_user))THEN
			UPDATE user SET name=_name, last_name=_last_name, ci=_ci, email=_email, 
			city=_city WHERE id=_id_user;
			UPDATE student SET college = _college, career=_career WHERE id_user=_id_user;
			SELECT 'Registro actualizado correctamente' as respuesta, 'not' as error;
        ELSE
			IF(SELECT EXISTS( SELECT * FROM professional WHERE id_user=_id_user))THEN
				UPDATE user SET name=_name, last_name=_last_name, ci=_ci, email=_email, 
				city=_city WHERE id=_id_user;
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
  `paid` tinyint(1) NOT NULL DEFAULT '0',
  `registration_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `name`, `last_name`, `ci`, `email`, `city`, `paid`, `registration_date`) VALUES
(132, 'aaa', 'aaaa', 'aaa', 'aa', 'aaa', 0, '2017-08-14 19:03:19'),
(133, 'Anahi Denisse', 'Contreras Buenaverez', '9981069', 'anahi.denisse.buena@gmail.com', 'La Paz', 0, '2017-08-14 22:20:04'),
(134, 'test', 'test', 'test', 'test@gmail.com', 'test', 0, '2017-08-14 22:27:36'),
(137, 'Diana Vanessa', 'Silva Arando', '7071807 LP', 'dianavanessa.dvsa@gmail.com', 'La Paz', 0, '2017-08-15 00:18:35'),
(138, 'Alvaro David', 'Copa', '6901086', 'copa730@gmail.com', 'La Paz', 0, '2017-08-15 00:42:42'),
(139, 'Jesus Juan Carlos', 'Maraza Vigabriel', '8321156', 'carlosmaraza@gmail.com', 'La Paz', 0, '2017-08-15 01:43:49'),
(140, 'Tatiana Germania', 'Chumacero Garcia', '4763971', 'chumacerotatiana@gmail.com', 'La Paz', 0, '2017-08-15 01:47:33'),
(141, 'VICTOR ALEJANDRO', 'ALCON CONDORI', '6964035', 'v.alejandro.alcon.c@gmail.com', 'La Paz', 0, '2017-08-15 01:48:37'),
(142, 'Cristhian Mauricio', 'Flores Vargas', '8352041', 'flovarmau@gmail.com', 'La Paz', 0, '2017-08-15 01:59:16'),
(143, 'Pamela Sesi', 'Uruchi Condori', '6966987 LP', 'pamelauruchi1@gmail.com', 'La Paz', 0, '2017-08-15 02:00:15'),
(144, 'Marisabel', 'Condori Cano', '10928881 Lp', 'mari.17ymy@gmail.com', 'La Paz', 0, '2017-08-15 02:17:08'),
(145, 'Alejandro', 'Mancilla', '8359856', 'alejandro-mancilla@outlook.com', 'La Paz', 0, '2017-08-15 02:21:07'),
(146, 'Maribel Maritza', 'Calle Averanga', '9241807', 'maryel.2mary@gmail.com', 'La Paz', 0, '2017-08-15 02:55:37'),
(147, 'Miguel Demetrio', 'Oropeza Quisbert', '9879793', 'demetrio947@yahoo.es', 'La Paz', 0, '2017-08-15 02:56:49'),
(148, 'Roberto Ruslan', 'Chambi Matha', '8324915', 'roby.mat11@gmail.com', 'La Paz', 0, '2017-08-15 03:53:01'),
(149, 'Aleyda Verónica', 'Villa-Gómez Zuleta', '5676656', 'aleve.villagomez.zuleta.93@gmail.com', 'Tarija', 0, '2017-08-15 04:02:34'),
(150, 'Marco Vladimir', 'Ordoñez Marca', '6732337', 'mvladyom@gmail.com', 'La Paz', 0, '2017-08-15 04:04:14'),
(151, 'Neith', 'Cabrera Colque', '7055848', 'cabrera.ne.93@gmail.com', 'La Paz', 0, '2017-08-15 04:54:05'),
(152, 'Claudia', 'Yupanqui Aruni', '8386621', 'yaczoe@gmail.com', 'La Paz', 0, '2017-08-15 06:30:49'),
(153, 'Aldo Samuel', 'Carrasco Fernandez', '7066860', 'aldosamycarras@gmail.com', 'La Paz', 0, '2017-08-15 06:30:54'),
(154, 'Natalia', 'Oviedo Acosta', '7745114 SC', 'natalia_o_95@hotmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-15 09:31:08'),
(155, 'Indira Noemi', 'Poma Canaviri', '8304469', 'indirapoma_c@outlook.com', 'La Paz', 0, '2017-08-15 12:00:32'),
(156, 'Genaro Mauricio', 'Alvarez Orias', '8460428 LP', 'naroalvarez97@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-15 14:29:07'),
(157, 'Misael Elias', 'Zubieta Callizaya', '4218896', 'zubieta1090@gmail.com', 'Cobija', 0, '2017-08-15 15:01:12'),
(158, 'Alvaro Ariel', 'Martínez Mancilla', '11109097', 'alvaro_dudutex@outlook.es', 'La Paz', 0, '2017-08-15 15:04:44'),
(159, 'Jose Luis', 'Quisbert Quisbert', '6992211', 'jose.luis.quisbert@gmail.com', 'La Paz', 0, '2017-08-15 15:06:40'),
(160, 'Alvaro', 'Perales Lopez', '4911089', 'aplotomamos@gmail.com', 'La Paz', 0, '2017-08-15 15:10:07'),
(161, 'Virginia', 'Mamani Cari', '8326617', 'vicky.cari.1410@gmail.com', 'La Paz', 0, '2017-08-15 15:14:35'),
(162, 'Roxana Reyna', 'Sanchez Falcon', '6964253', 'infdeus@gmail.com', 'La Paz', 0, '2017-08-15 15:23:48'),
(163, 'Kheyvit Arman', 'Paniagua Medina', '9899014', 'kheyvitoopaniagua@gmail.com', 'La Paz', 0, '2017-08-15 15:26:58'),
(164, 'Juan carlos', 'Gallardo Jiménez', '2637323 lp', 'jcgj.gallardo@gmail.com', 'Cobija', 0, '2017-08-15 15:28:00'),
(165, 'Pamela Evelin', 'Mamani Ulo', '7054649', 'eveseves123@hotmail.com', 'La Paz', 0, '2017-08-15 15:29:06'),
(166, 'KARIM MARISOL', 'CORI POMA', '10930367', 'karimmarisolcoripoma@gmail.com', 'La Paz', 0, '2017-08-15 15:30:49'),
(167, 'Jimmy Luis', 'Laruta Villarreal', '4202641', 'jdme3902@gmail.com', 'Cobija', 0, '2017-08-15 15:32:14'),
(168, 'Agustin', 'Zepita Quispe', '8323815', 'zepas123@hotmail.com', 'La Paz', 0, '2017-08-15 15:32:49'),
(169, 'CINTIA FAVIOLA', 'RIVERO CHINCHE', '5713797', 'cfaviolarivero7@gmail.com', 'Cobija', 0, '2017-08-15 15:38:52'),
(170, 'Daniel Alejandro', 'Gutierrez Montaño', '6676790', 'dagmcisco@gmail.com', 'Sucre', 0, '2017-08-15 15:45:02'),
(171, 'Jhovanna Magaly', 'Aldunate Cruz', '7225576', 'aldunatejhovanna@gmail.com', 'Tarija', 0, '2017-08-15 15:46:07'),
(172, 'Hasta Cuando va a seguir', 'Robando el Ugri y la manga de vagos?', '323233', 'tuhermana@gmail.com', 'Sucre', 0, '2017-08-15 16:45:51'),
(173, 'GLADYS ROSSEMARY', 'ZAPATA LAYME', '4021762', 'glazapata@hotmail.com', 'Oruro', 0, '2017-08-15 17:03:01'),
(174, 'Jorge Miguel', 'Mamani Lima', '8315617', 'miquimao047@gmail.com', 'La Paz', 0, '2017-08-15 17:58:16'),
(175, 'aaaa', 'bbbb', '1234567', 'ejemplo@algo.com', 'San Ignacio de Velasco', 0, '2017-08-15 17:58:42'),
(176, 'Cesar Hugo', 'choque Gutiérrez', '12407319', 'ces.123.lin5@gmail.com', 'Potosí', 0, '2017-08-15 17:58:54'),
(177, 'Erwin', 'Méndez Mejía', '12517815', 'erwinXYZ1@gmail.com', 'Sucre', 0, '2017-08-15 18:06:20'),
(178, 'Fabio Daniel', 'Choque Mamani', '6795129', 'oscaroscarlq@gmail.com', 'La Paz', 0, '2017-08-15 18:10:03'),
(179, 'YECID JUNIOR', 'VELASQUEZ FERREL', '9106240', 'velasquezyecid@gmail.com', 'La Paz', 0, '2017-08-15 19:00:16'),
(180, 'Adrian', 'Baldiviezo Colque', '9640451', 'baldiviezo.colque.adrian@gmail.com', 'Sucre', 0, '2017-08-15 19:41:45'),
(181, 'Cimar Hernan', 'Meneses España', '5078369', 'cimar.meneses@gmail.com', 'Potosi', 0, '2017-08-15 20:22:28'),
(182, 'Jose luis', 'Fernandez flores', '5757824', 'josefernandezflores83@gmail.com', 'Oruro', 0, '2017-08-15 20:54:54'),
(183, 'Lino Fernando', 'Villca Jaita', '10540930', 'linfer94@gmail.com', 'Sucre', 0, '2017-08-15 20:58:07'),
(184, 'Raúl', 'Ayllón Manrrique', '8536544', 'raul.ayllon.manrrique@gmail.com', 'Tarija', 0, '2017-08-15 21:00:10'),
(185, 'Carlos', 'Llanos Rodriguez', '7209948', 'carlosraiton@gmail.com', 'Tarija', 0, '2017-08-15 21:20:17'),
(186, 'Elvis Edson', 'Basilio Chambi', '10674508', 'elvis.2e3@gmail.com', 'Tarija', 0, '2017-08-15 21:21:19'),
(187, 'Ives Gabriel', 'Pereira Velasco', '5090593', 'ivespv@gmail.com', 'Potosi', 0, '2017-08-15 21:32:16'),
(188, 'Gudnar Rodrigo', 'Illanes Fernández', '8363750 LP', 'gudnarillanes@gmail.com', 'La Paz', 0, '2017-08-15 22:01:23'),
(189, 'Rocio', 'Chipana Luna', '6958285 LP.', 'rouss.zero@gmail.com', 'La Paz', 0, '2017-08-15 22:07:27'),
(190, 'Yoel', 'Villanueva Cabrera', '8357764', 'yvillanueva612@gmail.com', 'La Paz', 0, '2017-08-15 22:16:21'),
(191, 'Cristhian Kevin', 'Huanca Mollo', '6938184', 'cristhian.kevin.huanca.77@gmail.com', 'La Paz', 0, '2017-08-15 22:25:26'),
(192, 'David Ramiro', 'Zenteno Callisaya', '4854447', 'davidrdzc19@gmail.com', 'Cobija', 0, '2017-08-15 22:35:06'),
(193, 'Ayelen Claudia', 'Torres Choque', '14023092', 'clausaye190@gmail.com', 'Potosí', 0, '2017-08-15 22:58:52'),
(194, 'yessica', 'ortega vargas', '12367715', 'yessicaov4@gmail.com', 'Sucre', 0, '2017-08-15 23:08:03'),
(195, 'Dania Veronica', 'Ayarachi Gomez', '10477054', 'Daniagomez162@gmail.com', 'Potosi', 0, '2017-08-15 23:26:35'),
(196, 'David', 'Sullcani', '7017236', 'twanaq3100bx@gmail.com', 'La Paz', 0, '2017-08-15 23:35:43'),
(197, 'Annabel Carolina', 'Acarapi Cruz', '6940438', 'anniac0296@gmail.com', 'La Paz', 0, '2017-08-15 23:44:48'),
(198, 'Grace Minerva', 'Caballero Michel', '8595373', 'caballeromichelg@gmail.com', 'Potosi', 0, '2017-08-15 23:45:44'),
(199, 'Diego Ariel', 'Cortéz Fernández', '4210550 pdo', 'dcortezfer@gmail.com', 'Cobija', 0, '2017-08-16 00:04:16'),
(200, 'Williams Alejandro', 'Cruz Castro', '9140480', 'alescito113@gmail.com', 'La Paz', 0, '2017-08-16 00:54:08'),
(201, 'Jose Manuel', 'Jerez Viaña', '8583371', 'manueljosejv@gmail.com', 'Sucre', 0, '2017-08-16 01:40:59'),
(202, 'Luis Fernando', 'Rojas Arroyo', '7509786', 'rojasfernando443@gmail.com', 'Sucre', 0, '2017-08-16 03:13:14'),
(203, 'WINDSOR', 'ALVAREZ DAVILA', '756420', 'windsoralvarezdavila@gmail.com', 'Sucre', 0, '2017-08-16 03:30:09'),
(204, 'Bryan Abad', 'Pérez Gonzáles', '7216830', 'perez1195_03@hotmail.com', 'Tarija', 0, '2017-08-16 03:43:15'),
(205, 'Luis Fernando', 'Tejerina Tejerina', '10832674', 'fernandotejerina8@gmail.com', 'Santa Cruz de la Sierra', 0, '2017-08-16 03:46:56'),
(206, 'Edyth Ivon', 'Quispe Cala', '12667547', 'edit.leinknss7@gmail.com', 'La Paz', 0, '2017-08-16 14:11:37'),
(207, 'Maria Isabel', 'Huampo Laura', '11107398', 'marseonji@gmail.com', 'La Paz', 0, '2017-08-16 14:19:28'),
(208, 'Jose antonio', 'Rojas quispe', '12761177', 'jarq381@gmail.com', 'La Paz', 0, '2017-08-16 14:28:35'),
(209, 'Muriel Carla', 'Soto paredes', '8348910', 'carlita.soto.111@gmail.com', 'La Paz', 0, '2017-08-16 14:29:14'),
(210, 'emerson antonio', 'ibañez torrez', '9903437', 'emersonantonio666@gmail.com', 'la paz', 0, '2017-08-16 14:35:20'),
(211, 'FAVIO HERNAN', 'ACARAPI CALLISAYA', '8302760', 'Favian.acarapi@gmail.com', 'La Paz', 0, '2017-08-16 14:41:23'),
(212, 'Brian Angelo', 'Lopez Torrico', '7603596', 'angelo.lt.91@gmail.com', 'Trinidad', 0, '2017-08-16 15:22:11'),
(213, 'Mauricio Alvaro', 'Rodriguez Calliconde', '6942104', 'maurialvarorc@gmail.com', 'La Paz', 0, '2017-08-16 15:46:25'),
(214, 'Miguel Arturo', 'Colque Flores', '6813634', 'miguelcolquef@gmail.com', 'La Paz', 0, '2017-08-16 15:50:31'),
(215, 'Mishel Diana', 'Flores Urrutia', '10901297', 'mishelvision@gmail.com', 'La Paz', 0, '2017-08-16 16:16:59'),
(216, 'Luis', 'Bautista Baptista', '6688062', 'luisfarkas@gmail.com', 'Sucre', 0, '2017-08-16 16:23:03'),
(217, 'Luis 45', 'hijos de tu34', '76722332P', 'lkaslkd@gmks.cl', 'potosi', 0, '2017-08-16 16:27:14'),
(218, 'juan56', 'perez perez', '65124579', 'perez@gmial.com', 'La Paz', 0, '2017-08-16 16:31:19'),
(219, 'Juan', 'Perez Juarez', '75463534', 'eso@hotmail.com', 'Sucre', 0, '2017-08-16 16:31:31'),
(220, 'evo1', 'morales1', '111', 'puto@dhd.com', 'Sucre', 0, '2017-08-16 16:34:03'),
(221, 'evo1', 'morales1', '1111', 'puto@hd.com', 'Sucre', 0, '2017-08-16 16:36:07'),
(222, 'evo1', 'morales1', '444', 'asas@dia.com', 'sucrete', 0, '2017-08-16 16:40:45'),
(223, 'ivan eddy', 'consori fuentes', '11100893', 'ivaneddyfuentescondori@gmail.com', 'La Paz', 0, '2017-08-16 16:44:25'),
(224, 'Lenny Mariel', 'Diaz', '7571312', 'lennymariel.diaz@gmail.com', 'Sucre', 0, '2017-08-16 17:01:10'),
(225, 'Marcelo', 'Torrez Azuga', '9178348', 'elmac395@gmail.com', 'La paz', 0, '2017-08-16 17:22:24'),
(226, 'Juan Enrique Dempsey', 'Rivera Quisberth', '6870545', 'juane222333@gmail.com', 'La Paz', 0, '2017-08-16 17:26:00'),
(227, 'Mery Vanessa', 'Mamani Paco', '9202563', 'merypretty28@gmail.com', 'La Paz', 0, '2017-08-16 18:21:53'),
(228, 'Claudia', 'Mamani Chino', '9887059', 'claumch123@gmail.com', 'La Paz', 0, '2017-08-16 18:34:55');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=229;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
