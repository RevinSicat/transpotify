---

# Transpotify Project Architecture & Blueprint

## 1. Directory & File Structure Blueprint
```text
lib/
│   main.dart
│   
└───src/
    ├───common/
    │   ├───theme/
    │   │   ├─── app_theme.dart             # Dark/Light ThemeData & color tokens
    │   │   └─── app_colors.dart            # Badge & transport mode colors
    │   ├───utils/
    │   │   └─── common_utilities.dart      # Formatters (duration calculation, time diffs)
    │   └───widgets/
    │       ├─── schedule_card.dart         # 5-row reusable card component
    │       ├─── segment_accordion.dart     # Segment list breakdown widget
    │       ├─── day_badge.dart             # Days of week badge row widget
    │       └─── status_badge.dart          # Active / Completed status indicators
    │
    ├───core/
    │   ├───database/
    │   │   ├─── database.dart              # Main Drift / SQLite database entrypoint
    │   │   ├─── converters/
    │   │   │   └─── days_of_week_converter.dart # List<String> <-> DB String converter
    │   │   ├─── schedule/
    │   │   │   ├─── schedules.dart         # Table definition: Schedule
    │   │   │   ├─── schedule_segments.dart # Table definition: ScheduleSegment
    │   │   │   └─── dao/
    │   │   │       └─── schedule_dao.dart  # DAOs for schedule CRUD & stats query
    │   │   └─── transit/
    │   │       ├─── transit_logs.dart      # Table definition: TransitLog
    │   │       ├─── transit_segment_logs.dart # Table definition: TransitSegmentLog
    │   │       └─── dao/
    │   │           └─── transit_dao.dart   # DAOs for active state & log history
    │   │
    │   └───navigation/
    │       └─── app_router.dart            # GoRouter or native Navigator route specs
    │
    ├───features/
    │   ├───schedule/
    │   │   ├─── controllers/               # StateNotifier / Riverpod / Bloc
    │   │   │   └─── schedule_controller.dart
    │   │   └─── models/                    # Schedule with segments domain model
    │   │       └─── schedule_with_segments.dart
    │   └───transit/
    │       ├─── controllers/               # Active commute state machine
    │       │   └─── active_transit_controller.dart
    │       └─── models/                    # Commute progress & analytics models
    │           └─── active_transit_state.dart
    │
    └───pages/
        ├─── home_page.dart                 # Schedule card stack & average commute
        ├─── schedule_page.dart             # List of schedules & editor modal
        ├─── transit_logs_page.dart         # Historical logs accordion list
        └─── active_transit_page.dart       # Dynamic Board/Alight & dynamic updates

```

---

## 2. Complete Database Schema Specifications

```
+------------------+         1:N         +--------------------------+
|  Schedule Table  | ------------------< |  Schedule Segment Table  |
+------------------+                     +--------------------------+
         |                                            |
     1:N |                                        1:N |
         v                                            v
+------------------+         1:N         +--------------------------+
| Transit Log Tbl  | ------------------< | Transit Segment Log Tbl  |
+------------------+                     +--------------------------+

```

### Table Definitions

1. **`Schedules`** (`lib/src/core/database/schedule/schedules.dart`)
* `id`: Auto-incrementing Integer Primary Key
* `name`: Text
* `targetStartTime`: Text (`HH:mm` string representation)
* `targetArrivalTime`: Text (`HH:mm` string representation)
* `daysOfWeek`: Text (converted via `days_of_week_converter.dart`, e.g., `'Mn,Tu,Wd,Th,Fr'`)
* `isActive`: Boolean (default `true`)


2. **`ScheduleSegments`** (`lib/src/core/database/schedule/schedule_segments.dart`)
* `id`: Auto-incrementing Integer Primary Key
* `scheduleId`: Integer (Foreign Key $\rightarrow$ `Schedules.id`, Cascade Delete)
* `transportMode`: Text Enum (`walk`, `bus`, `train`, `minibus`, `car`, `motorcycle`, `bike`, `other`)
* `name`: Text (e.g., "LRT Line 1")
* `orderIndex`: Integer (0, 1, 2...)
* `estimatedDurationMinutes`: Integer


3. **`TransitLogs`** (`lib/src/core/database/transit/transit_logs.dart`)
* `id`: Auto-incrementing Integer Primary Key
* `scheduleId`: Integer (Foreign Key $\rightarrow$ `Schedules.id`)
* `date`: DateTime / Text (`YYYY-MM-DD`)
* `status`: Text Enum (`active`, `completed`, `cancelled`)
* `createdAt`: DateTime
* `completedAt`: DateTime (nullable)


4. **`TransitSegmentLogs`** (`lib/src/core/database/transit/transit_segment_logs.dart`)
* `id`: Auto-incrementing Integer Primary Key
* `transitLogId`: Integer (Foreign Key $\rightarrow$ `TransitLogs.id`, Cascade Delete)
* `scheduleSegmentId`: Integer (Foreign Key $\rightarrow$ `ScheduleSegments.id`)
* `boardedAt`: DateTime (nullable)
* `alightedAt`: DateTime (nullable)
* `actualDurationMinutes`: Integer (nullable, computed on alight)



---

## 3. Step-by-Phase Execution Plan for AIs/Developers

1. **Phase 1: Database Infrastructure & DAOs:** Directory setup, schema definitions, and converters.
* **Task 1.1:** Finalize Drift/SQLite tables in `lib/src/core/database/`.
* **Task 1.2:** Implement `days_of_week_converter.dart` to seamlessly convert Dart `List<String>` to database text.
* **Task 1.3:** Implement `schedule_dao.dart` with methods to create schedules with segments, fetch schedules, and aggregate segment averages.
* **Task 1.4:** Implement `transit_dao.dart` with methods to fetch the currently active log and fetch historical logs.
* **Acceptance Criteria:** `flutter pub run build_runner build` succeeds without schema or code-generation errors.


2. **Phase 2: Business Logic & State Management:** State machines and analytics logic.
* **Task 2.1 (`common_utilities.dart`):** Implement variance calculations:
* $\text{Expected Duration} = \text{targetArrivalTime} - \text{targetStartTime}$
* $\text{Average Duration} = \text{mean of historical actual durations for completed logs}$
* $\text{Variance} = \text{Average Duration} - \text{Expected Duration}$ (e.g., "15mins less than expected time").


* **Task 2.2 (`active_transit_controller.dart`):** Implement state transitions:
* `startCommute(scheduleId)`: Creates active `TransitLog` and empty `TransitSegmentLogs`.
* `boardSegment(segmentLogId)`: Writes current timestamp to `boardedAt`.
* `alightSegment(segmentLogId)`: Writes current timestamp to `alightedAt` and computes `actualDurationMinutes`.
* `completeCommute(transitLogId)`: Sets status to `completed` and records `completedAt`.


* **Acceptance Criteria:** Transitions lock previous segments once alighted and advance active pointer to the next index.


3. **Phase 3: Core UI Components:** Widget building in lib/src/common/widgets/.
* **Task 3.1 (`schedule_card.dart`):** Implement the 5-row schedule card:
* **Row 1:** `isActive` badge + 3-dots popup menu button.
* **Row 2:** Truncated Schedule Name (with `TextOverflow.ellipsis`) + Average Commute Duration & variance label.
* **Row 3:** `targetStartTime` $\rightarrow$ `targetArrivalTime`.
* **Row 4:** Day badges (`Mn`, `Tu`, `Wd`, `Th`, `Fr`, `Sa`, `Su`).
* **Row 5:** Conditional "Start Commute" or "Resume Active Commute" button.


* **Task 3.2 (`segment_accordion.dart`):** Build expansion panel showing sequence of segments with mode icons and average times.
* **Acceptance Criteria:** Widgets cleanly handle overflow text and display correct badge colors per transport mode.


4. **Phase 4: Page Construction & Navigation:** Screens in lib/src/pages/.
* **Task 4.1 (`home_page.dart`):** Render schedule card stack / selector, segment accordion, and average commute metrics. (Implemented)
* **Task 4.2 (`schedule_page.dart`):** Render vertical schedule list and floating action button (FAB) / modal to build new schedules and segments. (Implemented)
* **Task 4.3 (`transit_logs_page.dart`):** Render past logs grouped by date with expandable accordions showing segment actual vs estimated durations. (Implemented)
* **Task 4.4 (`active_transit_page.dart`):** (Implemented)
* Display active schedule header.
* Render dynamic main action button (`Board [Mode]` or `Alight [Mode]`).
* Render active segment timeline widget below the primary button.


* **Acceptance Criteria:** Verified by widget tests: Home $\rightarrow$ Start Commute $\rightarrow$ Board/Alight Segments $\rightarrow$ Finish Commute $\rightarrow$ Appears in Logs. Android debug build succeeds.


5. **Phase 5: Crash Persistence & Polish:** State restoration and edge cases.
* **Task 5.1:** Ensure `active_transit_controller.dart` checks `transit_dao.dart` on app startup to restore state if app crashes mid-commute.
* **Task 5.2:** Add a "Cancel Commute" option to set `status = cancelled`.
* **Acceptance Criteria:** App reload during an active commute re-opens directly or points to the active transit without losing timestamps.
---