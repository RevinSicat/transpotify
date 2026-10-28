abstract final class TransitLogStatus {
    static const active = 'active';
    static const completed = 'completed';
    static const cancelled = 'cancelled';
}

abstract final class SegmentLogStatus {
    static const pending = 'pending';
    static const inTransit = 'in_transit';
    static const completed = 'completed';
    static const skipped = 'skipped';
}