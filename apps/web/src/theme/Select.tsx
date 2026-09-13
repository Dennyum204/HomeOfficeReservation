import * as Primitive from "@radix-ui/react-select";
import {
  Children,
  Fragment,
  isValidElement,
  useCallback,
  useState,
  type ReactNode,
  type SelectHTMLAttributes,
  type ChangeEvent,
} from "react";
import "./select.css";

type Option = { value: string; label: ReactNode; disabled?: boolean };
function options(children: ReactNode): Option[] {
  return Children.toArray(children).flatMap((child) => {
    if (
      !isValidElement<{
        value?: string;
        children?: ReactNode;
        disabled?: boolean;
      }>(child)
    )
      return [];
    if (child.type === Fragment) return options(child.props.children);
    return [
      {
        value: String(child.props.value ?? ""),
        label: child.props.children,
        disabled: child.props.disabled,
      },
    ];
  });
}
const EMPTY = "__homeoffice_empty_option__";
export function Select({
  children,
  value,
  defaultValue,
  onChange,
  disabled,
  required,
  name,
  id,
  className,
  ...props
}: SelectHTMLAttributes<HTMLSelectElement>) {
  const [container, setContainer] = useState<HTMLElement | null>(null);
  const attach = useCallback((node: HTMLButtonElement | null) => {
    if (node) setContainer(node.closest("dialog") ?? document.body);
  }, []);
  const [local, setLocal] = useState(String(defaultValue ?? ""));
  const choices = options(children);
  const selected = String(value ?? local);
  return (
    <Primitive.Root
      value={selected || EMPTY}
      disabled={disabled}
      required={required}
      name={name}
      onValueChange={(raw) => {
        const next = raw === EMPTY ? "" : raw;
        setLocal(next);
        onChange?.({
          target: { value: next },
          currentTarget: { value: next },
        } as ChangeEvent<HTMLSelectElement>);
      }}
    >
      <Primitive.Trigger
        ref={attach}
        data-value={selected}
        id={id}
        className={`app-select ${className ?? ""}`}
        aria-label={props["aria-label"]}
        aria-labelledby={props["aria-labelledby"]}
        aria-describedby={props["aria-describedby"]}
        aria-invalid={props["aria-invalid"]}
      >
        <Primitive.Value>
          {choices.find((option) => option.value === selected)?.label}
        </Primitive.Value>
        <Primitive.Icon aria-hidden="true">⌄</Primitive.Icon>
      </Primitive.Trigger>
      <Primitive.Portal container={container}>
        <Primitive.Content
          className="app-select-menu"
          position="popper"
          sideOffset={4}
          collisionPadding={8}
          collisionBoundary={
            container?.tagName === "DIALOG" ? container : undefined
          }
          onEscapeKeyDown={(event) => event.stopPropagation()}
        >
          <Primitive.ScrollUpButton className="app-select-scroll">
            ⌃
          </Primitive.ScrollUpButton>
          <Primitive.Viewport>
            {choices.map((option) => (
              <Primitive.Item
                key={option.value}
                className="app-select-option"
                data-value={option.value}
                value={option.value || EMPTY}
                disabled={option.disabled}
              >
                <Primitive.ItemText>{option.label}</Primitive.ItemText>
                <Primitive.ItemIndicator aria-hidden="true">
                  ✓
                </Primitive.ItemIndicator>
              </Primitive.Item>
            ))}
          </Primitive.Viewport>
          <Primitive.ScrollDownButton className="app-select-scroll">
            ⌄
          </Primitive.ScrollDownButton>
        </Primitive.Content>
      </Primitive.Portal>
    </Primitive.Root>
  );
}
