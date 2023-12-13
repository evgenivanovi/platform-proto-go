package std

import (
	"time"

	"github.com/golang/protobuf/ptypes/timestamp"
	"google.golang.org/protobuf/types/known/timestamppb"
)

/* __________________________________________________ */

// NewTimestamp ...
func NewTimestamp(value *time.Time) *timestamp.Timestamp {
	if value == nil {
		return nil
	}
	return timestamppb.New(*value)
}

/* __________________________________________________ */

// NilOptionalTimestamp ...
func NilOptionalTimestamp() *OptionalTimestamp {
	return &OptionalTimestamp{Kind: nil}
}

// NewOptionalTimestamp ...
func NewOptionalTimestamp(value *time.Time) *OptionalTimestamp {
	if value == nil {
		return NilOptionalTimestamp()
	}
	return &OptionalTimestamp{
		Kind: &OptionalTimestamp_Data{
			Data: NewTimestamp(value),
		},
	}
}

/* __________________________________________________ */
