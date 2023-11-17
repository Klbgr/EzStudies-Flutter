<?php 

// Setting dummy filename according to OS, to keep cookies in memory
if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    $COOKIES_DUMMY_FILENAME = "NULL";
} else {
    $COOKIES_DUMMY_FILENAME = "/dev/null";
}

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
    curl_setopt($curl, CURLOPT_COOKIEJAR, $cookies_filename);
    curl_setopt($curl, CURLOPT_COOKIEFILE, $cookies_filename);
    curl_setopt($curl, CURLOPT_URL, 'https://services-web.cyu.fr/calendar/LdapLogin');
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
    $url = "https://services-web.cyu.fr/calendar/LdapLogin/Logon";
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
    global $COOKIES_DUMMY_FILENAME;
    $curl = curl_init();
    $result = cyuGetCookies($curl, $name, $password, $COOKIES_DUMMY_FILENAME);
    cyuClose($curl);
    return $result;
}

/**
 * Get calendar from Celcat for CYU's students
 * @param name Name of the student
 * @param password Password of the student
 * @return string Calendar of the student
 */
function cyuGetCalendar(string $name, string $password, string $id = null) : string {
    global $COOKIES_DUMMY_FILENAME;
    if ($name == null || $password == null || $name == "" || $password == "") {
        return "";
    }
    $curl = curl_init();
    $result = "";

    if (cyuGetCookies($curl, $name, $password, $COOKIES_DUMMY_FILENAME)) {
        // Getting calendar data
        if ($id == null) {
            parse_str(parse_url(curl_getinfo($curl, CURLINFO_EFFECTIVE_URL))['query'], $params);
            $id = $params['FederationIds'];
        }
        $timestamp = time();
        curl_setopt($curl, CURLOPT_URL, 'https://services-web.cyu.fr/calendar/Home/GetCalendarData');
        curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query(array('start' => date("Y-m-d", $timestamp - 60 * 60 * 24 * 15), 'end' => date("Y-m-d", $timestamp + 60 * 60 * 24 * 15), 'resType' => "104", "calView" => "listWeek", "federationIds[]" => $id)));
        curl_setopt($curl, CURLOPT_FOLLOWLOCATION, false);
        $result = curl_exec($curl);
    }

    cyuClose($curl);

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
    global $COOKIES_DUMMY_FILENAME;
    if ($name == null || $password == null || $name == "" || $password == "") {
        return "";
    }
    $curl = curl_init();
    $result = "";

    if (cyuGetCookies($curl, $name, $password, $COOKIES_DUMMY_FILENAME)) {
        // Getting calendar data
        curl_setopt($curl, CURLOPT_URL, 'https://services-web.cyu.fr/calendar/Home/ReadResourceListItems?myResources=false&searchTerm=' . $query . '&pageSize=1000&resType=104');
        $result = curl_exec($curl);
    }

    cyuClose($curl);

    return $result;
}

/**
 * Closes the curl session and deletes the cookies file
 * @param curl Curl
 */
function cyuClose($curl) : void {
    curl_close($curl);
}

?>