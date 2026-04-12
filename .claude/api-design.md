# API Design Standards

> **Note:** Technology-agnostic REST API principles. Adapt to your framework.

## RESTful Conventions

- Use RESTful methods (GET, POST, PUT, PATCH, DELETE). Prefer PATCH for partial updates
- Use plural nouns for endpoints (`/users`, not `/user`)
- Return proper HTTP status codes
- Use consistent response format (e.g., `{ success, data, error, meta }`)
- Document all endpoints with examples

## Contract-First Design

- Define API contracts (OpenAPI/Swagger) before implementation
- Use the spec as the single source of truth for frontend and backend
- Generate client SDKs and server stubs from the spec when possible
- Keep the spec in version control, update it before changing endpoints

## API Versioning

Choose one strategy consistently:

- **URL path** (recommended): `/api/v1/users`
- **Header**: `Accept: application/vnd.api+json;version=1`
- **Query param**: `/users?version=1`

Start with `v1` from day one. Add new version for breaking changes. Deprecate with `Sunset` header.

## HTTP Status Codes

- **200 OK**: Successful GET, PATCH, PUT, DELETE
- **201 Created**: Successful POST (include `Location` header)
- **204 No Content**: Successful DELETE with no body
- **304 Not Modified**: Resource unchanged (conditional request)
- **400 Bad Request**: Invalid input
- **401 Unauthorized**: Not authenticated
- **403 Forbidden**: Authenticated but not authorized
- **404 Not Found**: Resource doesn't exist
- **409 Conflict**: Resource conflict (e.g., duplicate)
- **422 Unprocessable Entity**: Validation errors (detailed)
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Unexpected error

## Response Format

```json
{
  "success": true,
  "data": { "..." },
  "error": null,
  "meta": { "page": 1, "pageSize": 20, "total": 150 }
}
```

Error response:

```json
{
  "success": false,
  "data": null,
  "error": {
    "message": "Validation failed",
    "code": "VALIDATION_ERROR",
    "fields": { "email": "Invalid email format" }
  }
}
```

## Pagination

- Paginate all list endpoints
- Default page size: 20 items, maximum: 100 items
- Query params: `?page=1&pageSize=20`
- Include pagination metadata in response `meta`

## Caching

- Use `ETag` and `If-None-Match` for conditional GET requests
- Return `304 Not Modified` when resource is unchanged
- Set `Cache-Control` headers appropriate to content:
  - Static assets: `public, max-age=31536000, immutable`
  - API responses: `private, no-cache` (revalidate each time)
  - Sensitive data: `no-store`
- Use `Last-Modified` / `If-Modified-Since` as alternative to ETags

## Idempotency

- GET, PUT, DELETE are naturally idempotent
- For POST/PATCH: accept an `Idempotency-Key` header for safe retries
- Store the key server-side, return the same response for duplicate requests
- Keys should expire after a reasonable period (e.g., 24 hours)

## URL Structure

```
GET    /users              # List (paginated)
GET    /users/:id          # Get one
POST   /users              # Create
PATCH  /users/:id          # Update
DELETE /users/:id          # Delete
GET    /users/:id/orders   # Nested resource
```
