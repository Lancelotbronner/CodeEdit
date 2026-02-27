//
//  Observation+.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2026-02-27.
//

import Observation

func withContinuousObservationTracking(
	_ apply: @escaping () -> Void,
) {
	withObservationTracking(apply) {
		withContinuousObservationTracking(apply)
	}
}
