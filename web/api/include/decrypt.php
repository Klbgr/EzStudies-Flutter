<?php

/**
 * Decrypt string
 * @param str String to decrypt
 * @return string Decrypted string
 */
function decrypt($str){
    $key = file_get_contents("./include/key");
    $iv = substr($key, 0, 16);
    return openssl_decrypt($str, 'aes-256-cbc', $key, 0, $iv);
}

?>