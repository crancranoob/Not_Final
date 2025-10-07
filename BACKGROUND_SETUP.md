# Background Setup Notes

To receive near real-time updates:
1. Enable **Background Modes**: Check **Background fetch** and **Background processing**.
2. Add **HealthKit** capability.
3. Add the BG task identifier to Info.plist:
   - `Permitted background task scheduler identifiers` → `com.hardychan.HealthAIAssistant`
   - `BGTaskSchedulerPermittedIdentifiers` → `com.hardychan.HealthAIAssistant.refresh`
4. In Signing & Capabilities, enable **iCloud Key-Value storage** if you want model weight sync.
5. For local notifications, the app will request permission on first launch.


## Night Training (Charging-only)
Add BG processing task identifier:
- `BGTaskSchedulerPermittedIdentifiers`: include `com.hardychan.HealthAIAssistant.nighttrain`

In **Signing & Capabilities → Background Modes**:
- Enable **Background processing**
- The scheduler requires **External Power**; we also gate runtime to **00:00–07:00**.

Training is **resumable** via checkpoint files (`checkpoint.json`). If unplugged mid-run, next run resumes and combines progress.


## Historical Import & Bootstrap
- First launch (or via Settings → 歷史匯入與個人化) can import 30–180 days of HealthKit history.
- After import, the app runs **charging-only** personalization. If not on charger or outside **00:00–07:00**, it schedules for the next window.
- Modules updated during bootstrap: **Teacher**, **Student (via distillation)**, **Experts**, **Meta Combiner**, **Calibrators**.
