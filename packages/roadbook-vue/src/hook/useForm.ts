import { objectUtil } from "@/helper/util";
import Schema, { Rules } from "async-validator";
import { Ref, UnwrapNestedRefs, reactive, ref } from "vue";

// 按照惯例，组合式函数名以“use”开头
export function useForm<T extends Object>(
  defaultValues: T,
  options: {
    rules?: Rules;
    onSubmit: (model: T) => void;
  }
): {
  loading: Ref<boolean>;
  model: UnwrapNestedRefs<T>;
  hints: Ref<Record<string, { error: boolean; hint: string }>>;
  validate: () => void;
  handleSubmit: () => void;
  reset: () => void;
} {
  const model = reactive<T>(Object.assign({}, defaultValues));
  const loading = ref<boolean>(false);

  const rules = new Schema(options.rules || {});

  const hints = ref<Record<string, { error: boolean; hint: string }>>({});

  const validate = () => {
    return new Promise((resolve, reject) => {
      rules.validate(model || {}, (errors) => {
        hints.value = {};
        if (errors) {
          errors.forEach((error) => {
            if (error.field) {
              hints.value[error.field] = {
                error: true,
                hint: error.message || "",
              };
            }
          });
          reject();
        }
        resolve(true);
      });
    });
  };

  function reset() {
    hints.value = {};
    Object.assign(model, defaultValues);
  }

  async function handleSubmit() {
    try {
      loading.value = true;
      await validate();
      const data = objectUtil.omitEmpty(model)
      await options.onSubmit(data as T);
      loading.value = false;
    } catch (e) {
      loading.value = false;
      console.error(e);
    }
  }

  return { loading, model, hints, validate, handleSubmit, reset };
}
