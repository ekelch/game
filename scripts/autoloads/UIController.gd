extends Node
var tooltip_label: Label;

func showTooltip(tooltip: String) -> void:
	tooltip_label.text = tooltip

func clearTooltip() -> void:
	if tooltip_label:
		tooltip_label.text = ""
