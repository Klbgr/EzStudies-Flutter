<?php 

require_once "./include/cyu.php";
require_once "./include/decrypt.php";

error_reporting(0);

if (!empty($_POST) && isset($_POST) && isset($_POST["request"])) {
    $request = $_POST["request"];
    switch ($request) {
        case "cyu":
            if (isset($_POST["name"]) && isset($_POST["password"])) {
                $name = decrypt($_POST["name"]);
                $password = decrypt($_POST["password"]);
                if (isset($_POST["id"])) {
                    $id = $_POST["id"];
                    echo cyuGetCalendar($name, $password, $id);
                } else {
                    echo cyuGetCalendar($name, $password);
                }
            }
            break;
        case "cyu_search":
            if (isset($_POST["name"]) && isset($_POST["password"]) && isset($_POST["query"])) {
                $name = decrypt($_POST["name"]);
                $password = decrypt($_POST["password"]);
                $query = $_POST["query"];
                echo cyuSearch($name, $password, $query);
            }
            break;
        case "cyu_check":
            if (isset($_POST["name"]) && isset($_POST["password"])) {
                $name = decrypt($_POST["name"]);
                $password = decrypt($_POST["password"]);
                echo cyuCheck($name, $password);
            }
            break;
    }
}

?>