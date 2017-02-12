//
//  SliderRowInt.swift
//  Pods
//
//  Created by Başar Oğuz on 12/02/17.
//
//

import UIKit

/// The cell of the SliderRow
public class SliderCellInt: Cell<Int>, CellType {
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var titleLabel: UILabel! {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, for: .horizontal)
        return textLabel
    }
    public var valueLabel: UILabel! {
        detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel?.setContentHuggingPriority(500, for: .horizontal)
        return detailTextLabel
    }
    lazy public var slider: UISlider = {
        let result = UISlider()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setContentHuggingPriority(500, for: .horizontal)
        return result
    }()
    public var formatter: NumberFormatter?
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        slider.minimumValue = Float(sliderRow.minimumValue)
        slider.maximumValue = Float(sliderRow.maximumValue)
        slider.addTarget(self, action: #selector(SliderCell.valueChanged), for: .valueChanged)
        
        if shouldShowTitle() {
            contentView.addSubview(titleLabel)
            contentView.addSubview(valueLabel!)
        }
        contentView.addSubview(slider)
        
        let views = ["titleLabel" : titleLabel, "valueLabel" : valueLabel, "slider" : slider] as [String : Any]
        let metrics = ["hPadding" : 16.0, "vPadding" : 12.0, "spacing" : 12.0]
        
        if shouldShowTitle() {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hPadding-[titleLabel]-[valueLabel]-hPadding-|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: metrics, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vPadding-[titleLabel]-spacing-[slider]-vPadding-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: metrics, views: views))
            
        } else {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vPadding-[slider]-vPadding-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: metrics, views: views))
        }
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hPadding-[slider]-hPadding-|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: metrics, views: views))
    }
    
    public override func update() {
        super.update()
        if !shouldShowTitle() {
            textLabel?.text = nil
            detailTextLabel?.text = nil
        }
        slider.value = Float(row.value!) ?? 0.0
    }
    
    func valueChanged() {
        let roundedValue: Float
        let steps = Float(sliderRow.steps)
        if steps > 0 {
            let stepValue = round((slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue) * steps)
            let stepAmount = (slider.maximumValue - slider.minimumValue) / steps
            roundedValue = stepValue * stepAmount + self.slider.minimumValue
        }
        else {
            roundedValue = slider.value
        }
        row.value = Int(roundedValue)
        if shouldShowTitle() {
            valueLabel.text = "\(row.value!)"
        }
    }
    
    private func shouldShowTitle() -> Bool {
        return row.title?.isEmpty == false
    }
    
    private var sliderRow: SliderRowInt {
        return row as! SliderRowInt
    }
}

/// A row that displays a UISlider. If there is a title set then the title and value will appear above the UISlider.

public final class SliderRowInt: Row<SliderCellInt>, RowType {
    
    public var minimumValue: Int = 0
    public var maximumValue: Int = 10
    public var steps: UInt = 20
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
