/**
 * URLSearchParamsから配列形式のパラメータを取得
 * @param paramName パラメータ名
 * @returns パースされた配列
 */
export const parseArrayFromQuery = (paramName: string): string[] => {
  // 現在のURLのクエリパラメータを取得
  const urlParams = new URLSearchParams(window.location.search);

  // getAll()メソッドで同名パラメータの配列を取得
  const arrayValues = urlParams.getAll(paramName);

  if (arrayValues.length > 0) {
    return arrayValues;
  }

  // 単一パラメータがカンマ区切りの場合も対応
  const singleParam = urlParams.get(paramName);
  if (singleParam) {
    return singleParam.split(',').map(item => item.trim()).filter(item => item !== '');
  }

  return [];
};

/**
 * 配列をURLクエリパラメータに変換
 * @param paramName パラメータ名
 * @param items 配列
 * @returns クエリ文字列
 */
export const arrayToQueryString = (paramName: string, items: string[]): string => {
  if (items.length === 0) return '';

  const params = new URLSearchParams();
  items.forEach(item => {
    params.append(paramName, item);
  });

  return params.toString();
};
