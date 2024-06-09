import { Ref, ref } from "vue";

export function useFetch<T>(callback: (page: number) => Promise<T[]>): {
  isFetching: Ref<boolean>;
  isFinished: Ref<boolean>;
  data: Ref<T[] | undefined>;
  fetch: (page?: number) => void;
  registerObserver: (selector: string) => void;
} {
  const isFetching = ref<boolean>(false);
  const isFinished = ref<boolean>(false);
  const data = ref<T[] | undefined>();
  async function fetch(page: number = 1) {
    try {
      if (page == 1) {
        data.value = [];
        isFinished.value = false;
      }
      if (isFetching.value || isFinished.value) return;
      isFetching.value = true;
      let result = await callback(page);
      if (result.length === 0) {
        isFinished.value = true;
      } else if (Array.isArray(data.value)) {
        data.value = data.value.concat(result);
      }
      isFetching.value = false;
    } catch (e) {
      isFetching.value = false;
      console.error(e);
    }
  }

  let page = 1;
  function registerObserver(selector: string) {
    const observer = new IntersectionObserver(
      (entries) =>
        !isFinished.value &&
        !isFetching.value &&
        entries[0].isIntersecting &&
        fetch(++page),
      {
        rootMargin: "0px",
        threshold: 1.0,
      }
    );
    const elem = document.querySelector(selector);
    elem && observer.observe(elem);
  }

  fetch();
  return { data, fetch, isFetching, isFinished, registerObserver };
}
