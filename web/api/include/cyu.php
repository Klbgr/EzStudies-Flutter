<?php 

/**
 * Get cookies to use Celcat's API
 * @param curl Curl
 * @param name Name of the student
 * @param password Password of the student
 * @param cookies_filename Filename to save the cookies to
 * @return True if cookies were successfully saved, false otherwise
 */
function cyuGetCookies($curl, string $name, string $password, string $cookies_filename) : bool {
    // Getting the cookies and HTML source code
    if (!file_exists("./cache")) {
        mkdir("./cache");
    }
    curl_setopt($curl, CURLOPT_COOKIEJAR, $cookies_filename);
    curl_setopt($curl, CURLOPT_COOKIEFILE, $cookies_filename);
    curl_setopt($curl, CURLOPT_URL, 'https://services-web.u-cergy.fr/calendar/LdapLogin');
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    if (($result = curl_exec($curl)) == false || $result == false) {
        return false;
    }

    // Getting verification token from HTML source code
    libxml_use_internal_errors(true); // Prevent warning messages
    $dom = new DOMDocument();
    $dom->validateOnParse = true;
    $dom->loadHTML($result);
    $xp = new DOMXpath($dom);
    $nodes = $xp->query('//input[@name="__RequestVerificationToken"]');
    $node = $nodes->item(0);
    if ($node == null) {
        return false;
    }
    $token = $node->getAttribute('value');
    if ($token == null || $token == "") {
        return false;
    }

    // Logging in and getting user cookies
    $url = "https://services-web.u-cergy.fr/calendar/LdapLogin/Logon";
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_POST, true);
    curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query(array('Name' => $name, 'Password' => $password, '__RequestVerificationToken' => $token)));
    curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true);
    $result = curl_exec($curl);
    if ($result == false || curl_getinfo($curl, CURLINFO_EFFECTIVE_URL) == $url) {
        return false;
    }
    return true;
}

/**
 * Check if credentials are valid
 * @param name Name of the student
 * @param password Password of the student
 */
function cyuCheck(string $name, string $password) : bool {
    $cookies_filename = "./cache/" . $name;
    $curl = curl_init();
    $result = cyuGetCookies($curl, $name, $password, $cookies_filename);
    cyuClose($curl, $cookies_filename);
    return $result;
}

/**
 * Get calendar from Celcat for CYU's students
 * @param name Name of the student
 * @param password Password of the student
 * @return string Calendar of the student
 */
function cyuGetCalendar(string $name, string $password, string $id = null) : string {
    if ($name == null || $password == null || $name == "" || $password == "") {
        return "";
    }
    $cookies_filename = "./cache/" . $name;
    $curl = curl_init();
    $result = "";

    if (cyuGetCookies($curl, $name, $password, $cookies_filename)) {
        // Getting calendar data
        if ($id == null) {
            parse_str(parse_url(curl_getinfo($curl, CURLINFO_EFFECTIVE_URL))['query'], $params);
            $id = $params['FederationIds'];
        }
        $timestamp = time();
        curl_setopt($curl, CURLOPT_URL, 'https://services-web.u-cergy.fr/calendar/Home/GetCalendarData');
        curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query(array('start' => date("Y-m-d", $timestamp - 60 * 60 * 24 * 15), 'end' => date("Y-m-d", $timestamp + 60 * 60 * 24 * 15), 'resType' => "104", "calView" => "listWeek", "federationIds[]" => $id)));
        curl_setopt($curl, CURLOPT_FOLLOWLOCATION, false);
        echo curl_getinfo($curl, CURLOPT_POSTFIELDS);
        $result = curl_exec($curl);
    }

    cyuClose($curl, $cookies_filename);

    return $result;
}

/**
 * Search for a other student in Celcat
 * @param name Name of the student
 * @param password Password of the student
 * @param query Query to search for
 * @return string Search result
 */
function cyuSearch(string $name, string $password, string $query) : string {
    if ($name == null || $password == null || $name == "" || $password == "") {
        return "";
    }
    $cookies_filename = "./cache/" . $name;
    $curl = curl_init();
    $result = "";

    if (cyuGetCookies($curl, $name, $password, $cookies_filename)) {
        // Getting calendar data
        curl_setopt($curl, CURLOPT_URL, 'https://services-web.u-cergy.fr/calendar/Home/ReadResourceListItems?myResources=false&searchTerm=' . $query . '&pageSize=1000&resType=104');
        $result = curl_exec($curl);
    }

    cyuClose($curl, $cookies_filename);

    return $result;
}

/**
 * Closes the curl session and deletes the cookies file
 * @param curl Curl
 * @param cookies_filename Filename of the cookies file
 */
function cyuClose($curl, string $cookies_filename) : void {
    curl_close($curl);
    if (file_exists($cookies_filename)) {
        unlink($cookies_filename);
    };
}

?>