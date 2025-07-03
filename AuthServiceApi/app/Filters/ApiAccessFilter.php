<?php
namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;
use Config\Services;

class ApiAccessFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $origin      = $_SERVER['HTTP_ORIGIN'] ?? '';
        $remoteAddr  = $_SERVER['REMOTE_ADDR'] ?? '';
        $serverAddr  = $_SERVER['SERVER_ADDR'] ?? '';
        $host        = $_SERVER['HTTP_HOST'] ?? '';
        $userAgent   = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $requestUri  = $_SERVER['REQUEST_URI'] ?? '';
        $internalToken = $_SERVER['HTTP_X_INTERNAL_TOKEN'] ?? '';
        $expectedToken = env('internal.api.token'); // from .env

        $allowedOrigins = [
            'https://fabricadistribution.com',
            'https://dashboard.fabricadistribution.com',
        ];

        $isInternal = (
            $remoteAddr === $serverAddr ||
            $remoteAddr === '127.0.0.1' ||
            $remoteAddr === '::1' ||
            strpos($host, 'api.fabricadistribution.com') !== false
        );

        // (Optional) Detect Postman or Insomnia
        $isKnownTool = stripos($userAgent, 'Postman') !== false || stripos($userAgent, 'Insomnia') !== false;


        // ✅ Allow known origins (browser requests)
        if ($origin && in_array($origin, $allowedOrigins)) {
            header("Access-Control-Allow-Origin: $origin");
            header("Access-Control-Allow-Headers: Origin, Content-Type, Authorization, X-Requested-With, X-Internal-Token");
            header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
            header("Access-Control-Allow-Credentials: true");
            return;
        }

        // ✅ Allow internal API calls with token
        if (!$origin && $isInternal && $internalToken === $expectedToken && !$isKnownTool) {
            return;
        }

        // ❌ Deny everything else
        return Services::response()
            ->setStatusCode(403)
            ->setBody('Forbidden: Unauthorized access');
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        return $response;
    }
}
