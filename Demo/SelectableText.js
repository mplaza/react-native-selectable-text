import React from "react";
import { Text, requireNativeComponent, Platform } from "react-native";
import { v4 } from "uuid";

const RNSelectableText = requireNativeComponent("RNSelectableText");

/**
 * Props
 * ...TextProps
 * onSelection: ({ content: string, eventType: string, selectionStart: int, selectionEnd: int }) => void
 * children: ReactNode
 * highlights: array({ id, start, end })
 * highlightColor: string
 * onHighlightPress: string => void
 */
export const SelectableTextGroup = ({
  onSelection,
  value,
  children,
  ...props
}) => {
  const onSelectionNative = ({
    nativeEvent: { content, eventType, selectionStart, selectionEnd }
  }) => {
    onSelection &&
      onSelection({ content, eventType, selectionStart, selectionEnd });
  };

  const getInnerTextLength = props => {
    let textLength = 0;
    (function findAllChildren(props) {
      if (Array.isArray(props.children)) {
        props.children.map(child => {
          findAllChildren(child.props);
        });
      } else {
        if (props.children) {
          textLength += props.children.length;
        }
      }
    })(props);
    return textLength;
  };
  let numChar = 0;

  const extractTextProperties = props => {
    const rangeStart = numChar;
    const textLength = getInnerTextLength(props);
    numChar += textLength;
    const rangeEnd = numChar;
    const onPress = props.onPress;
    return { onPress, rangeStart, rangeEnd };
  };

  const childOnPressFunctions = children.map(child => {
    return extractTextProperties(child.props);
  });

  const onPressText = e => {
    const { clickedRangeStart, clickedRangeEnd } = e.nativeEvent;

    let onPressFunction;
    for (let i = 0; i < childOnPressFunctions.length; i++) {
      const { rangeStart, rangeEnd, onPress } = childOnPressFunctions[i];
      if (clickedRangeEnd <= rangeEnd && clickedRangeStart >= rangeStart) {
        onPressFunction = onPress;
        break;
      }
    }

    return onPressFunction && onPressFunction();
  };

  return (
    <RNSelectableText
      {...props}
      onHighlightPress={onPressText}
      selectable
      onSelection={onSelectionNative}
    >
      <Text selectable key={v4()}>
        <>{children}</>
        {props.appendToChildren ? props.appendToChildren : null}
      </Text>
    </RNSelectableText>
  );
};
