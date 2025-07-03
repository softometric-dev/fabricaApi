<?php

namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;

class Cors implements FilterInterface
{
    // public function before(RequestInterface $request, $arguments = null)
    // {
    //     // Add CORS headers
    //     header("Access-Control-Allow-Origin: *");
    //     header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization");
    //     header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

    //     // Handle preflight requests
    //     if ($request->getMethod() == "OPTIONS") {
    //         header("HTTP/1.1 200 OK");
    //         exit;
    //     }
    // }

    // public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    // {
    //     // Add CORS headers to the response
    //     $response->setHeader("Access-Control-Allow-Origin", "*")
    //              ->setHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
    //              ->setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    // }

     protected $allowedOrigins = [
        'https://fabricadistribution.com',
        'https://dashboard.fabricadistribution.com',
        'http://localhost:5173',
    ];

    public function before(RequestInterface $request, $arguments = null)
    {
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
        $userAgent  = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $isKnownTool = stripos($userAgent, 'Postman') !== false || stripos($userAgent, 'Insomnia') !== false;
        $allowPostman = env('ALLOW_POSTMAN', false); // allow in .env for dev only

       if ($isKnownTool && !$allowPostman) {
            header('HTTP/1.1 403 Forbidden');
            exit('Forbidden: Postman/Insomnia access not allowed');
        }


        if ($origin && in_array($origin, $this->allowedOrigins)) {
            header("Access-Control-Allow-Origin: $origin");
        } else {
            header("Access-Control-Allow-Origin: null");
        }
        

        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Origin, Content-Type, Authorization, X-Requested-With, X-Internal-Token");
        header("Access-Control-Allow-Credentials: true");

        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            exit(0);
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        return $response;
    }
}
