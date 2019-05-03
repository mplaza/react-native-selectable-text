
# react-native-selectable-text

Forked from @astrocoders/react-native-selectable-text, but doesn't allow for extra highlighting / highlight clicks but accepts nested text elements with onPress 

So for example, you can have a text paragraph with a hyperlink inside and all will be selectable

### Android

<img src="https://github.com/Astrocoders/react-native-selectable-text/raw/master/Demo/demo_android.gif" width="350px" />

### iOS

<img src="https://user-images.githubusercontent.com/16995184/54835973-055e7480-4ca2-11e9-8d55-c4f7a67c2847.gif" width="350px" />

## Usage

```javascript
import { SelectableTextGroup } from "react-native-selectable-text";

// Use normally, it is a drop-in replacement for react-native/Text
<SelectableTextGroup
  menuItems={["Foo", "Bar"]}
  /* 
    Called when the user taps in a item of the selection menu:
    - eventType: (string) is the label
    - content: (string) the selected text portion
    - selectionStart: (int) is the start position of the selected text
    - selectionEnd: (int) is the end position of the selected text
   */
  onSelection={({ eventType, content, selectionStart, selectionEnd }) => {}}
>
  <Text>Put whatever text here</Text>
  <Text onPress={() => {console.log('ive been clicked')}}>Even Links!</Text>
</SelectableTextGroup>
```

## Getting started

`$ npm install @astrocoders/react-native-selectable-text --save`

### Mostly automatic installation

`$ react-native link @astrocoders/react-native-selectable-text`

## Props
| name | description | type | default |
|--|--|--|--|
| **value** | text content | string | "" |
| **onSelection** | Called when the user taps in a item of the selection menu | ({ eventType: string, content: string, selectionStart: int, selectionEnd: int }) => void | () => {} |
| **menuItems** | context menu items | array(string) | [] |
| **style** | additional styles to be applied to text | Object | null |
| **appendToChildren** | element to be added in the last line of text | ReactNode | null |


