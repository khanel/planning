# Unified Data Model Specification

## Overview
The Planning App uses a denormalized, unified data model to store all core entities (e.g., tasks, user settings) in a single, flexible schema. This approach simplifies data access, enables efficient synchronization, and supports extensibility for future entity types.

## Unified Record Structure
Each record in the unified store contains the following fields:

- `id` (String): Unique identifier for the record.
- `type` (String): Entity type (e.g., `task`, `user_setting`).
- `createdAt` (DateTime): Timestamp of record creation.
- `updatedAt` (DateTime): Timestamp of last update.
- `data` (Map<String, dynamic>): Entity-specific payload (structure varies by type).

### Example
```json
{
  "id": "task-123",
  "type": "task",
  "createdAt": "2025-05-13T10:00:00Z",
  "updatedAt": "2025-05-13T10:05:00Z",
  "data": {
    "title": "Write unified data model spec",
    "description": "Document the unified data model for the app.",
    "dueDate": "2025-05-14T12:00:00Z",
    "completed": false
  }
}
```

## Supported Entity Types
- `task`: Represents a user task or to-do item.
- `user_setting`: Stores user preferences and configuration.

## Rationale
- **Simplicity:** One schema for all entities reduces code complexity.
- **Extensibility:** New entity types can be added by defining new `type` values and corresponding `data` payloads.
- **Sync-Friendly:** Denormalized structure is well-suited for local-first and offline-capable apps.

## Future Considerations
- Indexing strategies for efficient queries.
- Versioning of records for migration support.
- Encryption of sensitive fields in `data`.

---

_Last updated: 2025-05-13_
